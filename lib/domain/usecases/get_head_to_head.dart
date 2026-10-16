import '../entities/head_to_head_entry.dart';
import '../repositories/game_repository.dart';
import '../repositories/tab_repository.dart';

/// Win/loss record between this tab and each opponent it has played.
class GetHeadToHead {
  GetHeadToHead(this._games, this._tabs);

  final GameRepository _games;
  final TabRepository _tabs;

  Future<List<HeadToHeadEntry>> call(int tabId) async {
    final games = await _games.getAll();
    final won = <int, int>{};
    final lost = <int, int>{};
    for (final g in games) {
      if (g.winnerTabId == tabId) {
        won[g.loserTabId] = (won[g.loserTabId] ?? 0) + 1;
      } else if (g.loserTabId == tabId) {
        lost[g.winnerTabId] = (lost[g.winnerTabId] ?? 0) + 1;
      }
    }
    final opponentIds = {...won.keys, ...lost.keys};
    final result = <HeadToHeadEntry>[];
    for (final id in opponentIds) {
      final opponent = await _tabs.getById(id);
      if (opponent == null) continue;
      result.add(HeadToHeadEntry(
        other: opponent,
        wonAgainst: won[id] ?? 0,
        lostAgainst: lost[id] ?? 0,
      ));
    }
    result.sort((a, b) => b.wonAgainst.compareTo(a.wonAgainst));
    return result;
  }
}
