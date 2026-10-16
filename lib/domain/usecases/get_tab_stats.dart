import '../entities/tab_stats.dart';
import '../repositories/game_repository.dart';

/// Played / won / lost counts for a tab, derived from its games.
class GetTabStats {
  GetTabStats(this._games);

  final GameRepository _games;

  Future<TabStats> call(int tabId) async {
    final lost = (await _games.lostPricesFor(tabId)).length;
    final won = await _games.wonCountFor(tabId);
    return TabStats(played: won + lost, won: won, lost: lost);
  }
}
