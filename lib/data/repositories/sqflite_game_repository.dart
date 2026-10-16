import 'package:sqflite/sqflite.dart';

import '../../domain/entities/game.dart';
import '../../domain/repositories/game_repository.dart';

class SqfliteGameRepository implements GameRepository {
  SqfliteGameRepository(this._db);

  final Database _db;

  @override
  Future<Game> insert({
    required int stationId,
    required int winnerTabId,
    required int loserTabId,
    required int price,
  }) async {
    final playedAt = DateTime.now().millisecondsSinceEpoch;
    final id = await _db.insert('games', {
      'station_id': stationId,
      'winner_tab_id': winnerTabId,
      'loser_tab_id': loserTabId,
      'played_at': playedAt,
      'price': price,
    });
    return Game(
      id: id,
      stationId: stationId,
      winnerTabId: winnerTabId,
      loserTabId: loserTabId,
      playedAt: playedAt,
      price: price,
    );
  }

  @override
  Future<List<Game>> getAll() async {
    final rows = await _db.query('games', orderBy: 'played_at DESC, id DESC');
    return rows.map(Game.fromMap).toList();
  }

  @override
  Future<void> delete(int id) =>
      _db.delete('games', where: 'id = ?', whereArgs: [id]);

  @override
  Future<List<int>> lostPricesFor(int tabId) async {
    final rows = await _db.query(
      'games',
      columns: ['price'],
      where: 'loser_tab_id = ?',
      whereArgs: [tabId],
    );
    return rows.map((r) => r['price'] as int).toList();
  }
}
