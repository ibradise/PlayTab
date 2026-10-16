import '../entities/slot.dart';
import '../entities/station.dart';
import '../entities/undo_game_result.dart';
import '../repositories/game_repository.dart';
import '../repositories/station_repository.dart';

/// Undo for a single game from history.
///
/// - Deletes the game (owed amounts are derived, so they recalculate).
/// - Restores the station slots only when this game is the latest on its
///   station; otherwise slots are left as-is.
/// - Blocks with a conflict message if restoring would move a tab that has
///   since been placed on another station.
class UndoGame {
  UndoGame(this._games, this._stations);

  final GameRepository _games;
  final StationRepository _stations;

  Future<UndoGameResult> call(int gameId) async {
    final all = await _games.getAll();

    final target = all.where((g) => g.id == gameId).toList();
    if (target.isEmpty) {
      return const UndoGameResult(UndoStatus.notFound);
    }
    final game = target.first;

    final stationGames = all.where((g) => g.stationId == game.stationId);
    final latestId =
        stationGames.map((g) => g.id).reduce((a, b) => a > b ? a : b);
    final isLatestOnStation = game.id == latestId;

    if (isLatestOnStation) {
      final station = await _stations.getById(game.stationId);
      if (station != null) {
        final loserStation = await _stationWithTab(game.loserTabId);
        if (loserStation != null && loserStation.id != station.id) {
          return const UndoGameResult(
            UndoStatus.conflict,
            message: 'Loser has since moved to another station',
          );
        }

        final winnerSlot = station.slotATabId == game.winnerTabId
            ? Slot.a
            : (station.slotBTabId == game.winnerTabId ? Slot.b : null);
        if (winnerSlot != null) {
          final loserSlot = winnerSlot == Slot.a ? Slot.b : Slot.a;
          await _stations.clearSlot(station.id, loserSlot);
          await _stations.assignTab(station.id, loserSlot, game.loserTabId);
          await _games.delete(gameId);
          return const UndoGameResult(UndoStatus.done, restored: true);
        }
      }
    }

    await _games.delete(gameId);
    return const UndoGameResult(UndoStatus.done, restored: false);
  }

  Future<Station?> _stationWithTab(int tabId) async {
    final stations = await _stations.getAll();
    for (final station in stations) {
      if (station.hasTab(tabId)) return station;
    }
    return null;
  }
}
