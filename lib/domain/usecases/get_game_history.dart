import '../entities/game_history_entry.dart';
import '../repositories/game_repository.dart';
import '../repositories/station_repository.dart';
import '../repositories/tab_repository.dart';

/// Most recent games first, with station name and player labels resolved.
class GetGameHistory {
  GetGameHistory(this._games, this._stations, this._tabs);

  final GameRepository _games;
  final StationRepository _stations;
  final TabRepository _tabs;

  Future<List<GameHistoryEntry>> call() async {
    final games = await _games.getAll();
    final entries = <GameHistoryEntry>[];
    for (final g in games) {
      final station = await _stations.getById(g.stationId);
      final winner = await _tabs.getById(g.winnerTabId);
      final loser = await _tabs.getById(g.loserTabId);
      entries.add(GameHistoryEntry(
        game: g,
        stationName: station?.name ?? '?',
        winnerLabel: winner?.displayLabel ?? '#${g.winnerTabId}',
        loserLabel: loser?.displayLabel ?? '#${g.loserTabId}',
      ));
    }
    return entries;
  }
}
