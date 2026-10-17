import 'package:sqflite/sqflite.dart';

import '../../domain/entities/tab.dart';
import '../../domain/entities/tab_status.dart';
import '../../domain/repositories/tab_repository.dart';

class SqfliteTabRepository implements TabRepository {
  SqfliteTabRepository(this._db);

  final Database _db;

  @override
  Future<Tab> create({String? label}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final displayNumber = await _nextFreeDisplayNumber();
    final id = await _db.insert('tabs', {
      'label': label,
      'status': TabStatus.open.dbValue,
      'created_at': now,
      'display_number': displayNumber,
    });
    return Tab(
      id: id,
      label: label,
      status: TabStatus.open,
      createdAt: now,
      displayNumber: displayNumber,
    );
  }

  /// Smallest positive number not held by any open tab (closed tabs release
  /// their numbers, so they can be reused).
  Future<int> _nextFreeDisplayNumber() async {
    final rows = await _db.query(
      'tabs',
      columns: ['display_number'],
      where: 'status = ? AND display_number IS NOT NULL',
      whereArgs: [TabStatus.open.dbValue],
    );
    final taken = rows.map((r) => r['display_number'] as int).toSet();
    var candidate = 1;
    while (taken.contains(candidate)) {
      candidate++;
    }
    return candidate;
  }

  @override
  Future<List<Tab>> getOpen() async {
    final rows = await _db.query(
      'tabs',
      where: 'status = ?',
      whereArgs: [TabStatus.open.dbValue],
      orderBy: 'display_number, id',
    );
    return rows.map(Tab.fromMap).toList();
  }

  @override
  Future<Tab?> getById(int id) async {
    final rows =
        await _db.query('tabs', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Tab.fromMap(rows.first);
  }

  @override
  Future<void> updateLabel(int id, String label) => _db.update(
        'tabs',
        {'label': label},
        where: 'id = ?',
        whereArgs: [id],
      );

  @override
  Future<void> close(int id) => _db.update(
        'tabs',
        {
          'status': TabStatus.closed.dbValue,
          'closed_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
}
