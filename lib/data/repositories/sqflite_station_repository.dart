import 'package:sqflite/sqflite.dart';

import '../../domain/entities/slot.dart';
import '../../domain/entities/station.dart';
import '../../domain/repositories/station_repository.dart';

class SqfliteStationRepository implements StationRepository {
  SqfliteStationRepository(this._db);

  final Database _db;

  @override
  Future<List<Station>> getAll() async {
    final rows = await _db.query('stations', orderBy: 'id');
    return rows.map(Station.fromMap).toList();
  }

  @override
  Future<Station?> getById(int id) async {
    final rows =
        await _db.query('stations', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Station.fromMap(rows.first);
  }

  @override
  Future<void> assignTab(int stationId, Slot slot, int tabId) => _db.update(
        'stations',
        {slot.dbColumn: tabId},
        where: 'id = ?',
        whereArgs: [stationId],
      );

  @override
  Future<void> clearSlot(int stationId, Slot slot) => _db.update(
        'stations',
        {slot.dbColumn: null},
        where: 'id = ?',
        whereArgs: [stationId],
      );
}
