import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/exceptions.dart';

/// Backup = a single `VACUUM INTO` snapshot (consistent even while the app
/// is in use). Restore = close our connection, then copy the picked backup
/// file over the live one; the UI relaunches the app afterwards.
class BackupService {
  BackupService(this._db, this._dbPath);

  final Database _db;

  /// Absolute path of the live `playtab.db` on this device.
  final String _dbPath;

  String _backupName() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'playtab-backup-'
        '${now.year}-${two(now.month)}-${two(now.day)}'
        '-${two(now.hour)}${two(now.minute)}${two(now.second)}.db';
  }

  /// Creates a snapshot of the current data at [snapshotPath].
  Future<String> createSnapshot(String snapshotPath) async {
    await _db.execute('VACUUM INTO ?', [snapshotPath]);
    return snapshotPath;
  }

  /// Backup flow: produce a snapshot file next to the live database and
  /// return it (the UI hands it to the share sheet).
  Future<File> backup() async {
    final snapshotPath = p.join(p.dirname(_dbPath), _backupName());
    await createSnapshot(snapshotPath);
    return File(snapshotPath);
  }

  /// Restores [backup] over the live database: closes our connection first,
  /// then copies the file. After this returns the data file has been
  /// replaced and the app MUST be closed — a fresh launch picks the
  /// restored data up.
  Future<void> restore(File backup) async {
    if (!backup.existsSync()) {
      throw const ValidationException('Backup file not found');
    }
    if (!await _looksLikeSqlite(backup)) {
      throw const ValidationException('That file is not a backup');
    }
    // Guard: picking the live file itself would be a no-op confusion.
    if (p.canonicalize(backup.path) == p.canonicalize(_dbPath)) {
      throw const ValidationException(
        'Pick a backup file, not the live database',
      );
    }
    await _db.close();
    try {
      await backup.copy(_dbPath);
    } catch (e) {
      throw ValidationException('Restore failed: $e');
    } finally {
      debugPrint('Restore finished from ${backup.path}');
    }
  }

  /// SQLite files start with the magic header "SQLite format 3\0".
  Future<bool> _looksLikeSqlite(File file) async {
    final raf = await file.open();
    try {
      final header = await raf.read(16);
      return header.length == 16 &&
          String.fromCharCodes(header.sublist(0, 15)) == 'SQLite format 3';
    } catch (_) {
      return false;
    } finally {
      await raf.close();
    }
  }
}
