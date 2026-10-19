import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/backup/backup_service.dart';
import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_settings_repository.dart';
import 'package:playtab/domain/exceptions.dart';

void main() {
  sqfliteFfiInit();
  final dir =
      Directory.systemTemp.createTempSync('playtab_backup_test');

  setUp(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<(AppDatabase, Database)> openLive(String name) async {
    final appDb = AppDatabase(
      factory: databaseFactoryFfi,
      name: p.join(dir.path, name),
    );
    return (appDb, await appDb.database);
  }

  test('backup: VACUUM snapshot contains current data', () async {
    final (appDb, db) = await openLive('live.db');
    final settings = SqfliteSettingsRepository(db);
    await settings.setDarkMode(true);

    final service = BackupService(db, db.path);
    final file = await service.backup();

    expect(file.existsSync(), isTrue);

    // Open the snapshot and check the data is inside.
    final snapshotDb =
        await databaseFactoryFfi.openDatabase(file.path);
    final rows = await snapshotDb.query('settings');
    expect(rows.first['dark_mode'], 1);
    await snapshotDb.close();
    await appDb.close();
  });

  test('restore: replaces the live database with the backup', () async {
    final (appDb, db) = await openLive('live.db');
    // Current data: dark mode on.
    await SqfliteSettingsRepository(db).setDarkMode(true);

    // Older backup (made before that change).
    final service = BackupService(db, db.path);
    final backupPath = p.join(dir.path, 'older.db');
    await SqfliteSettingsRepository(db).setDarkMode(false);
    await service.createSnapshot(backupPath);
    await SqfliteSettingsRepository(db).setDarkMode(true);

    // Restore the older snapshot and reopen the live database fresh.
    await service.restore(File(backupPath));
    final appDb2 =
        AppDatabase(factory: databaseFactoryFfi, name: db.path);
    final fresh = await appDb2.database;
    expect((await SqfliteSettingsRepository(fresh).get()).darkMode,
        isFalse);

    await appDb2.close();
    await appDb.close();
  });

  test('restore: rejects non-sqlite files and missing files', () async {
    final (appDb, db) = await openLive('live.db');
    final service = BackupService(db, db.path);

    final garbage = File(p.join(dir.path, 'not-a-db.txt'))
      ..writeAsStringSync('hello world this is not sqlite');
    await expectLater(
      service.restore(garbage),
      throwsA(isA<ValidationException>()),
    );

    // The live database must still be usable after a rejected restore.
    expect(
      (await SqfliteSettingsRepository(db).get()).pricePerGame,
      15,
    );

    await expectLater(
      service.restore(File(p.join(dir.path, 'never-created.db'))),
      throwsA(isA<ValidationException>()),
    );

    // The first rejection keeps the connection open; still works later.
    expect(
      (await SqfliteSettingsRepository(db).get()).pricePerGame,
      15,
    );

    await appDb.close();
  });
}
