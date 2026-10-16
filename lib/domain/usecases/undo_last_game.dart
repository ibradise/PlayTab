import '../entities/slot.dart';
import '../repositories/game_repository.dart';
import '../repositories/station_repository.dart';

/// Undo for the most recent game: deletes it and restores the winner/loser
/// into their previous slots.
class UndoLastGame {
  UndoLastGame(this._games, this._stations);

  final GameRepository _games;
  final StationRepository _stations;

  Future<void> call() async {
    final games = await _games.getAll();
    if (games.isEmpty) return;
    final game = games.first;

    await _games.delete(game.id);

    final station = await _stations.getById(game.stationId);
    if (station == null) return;

    final winnerSlot =
        station.slotATabId == game.winnerTabId ? Slot.a : Slot.b;
    final loserSlot = winnerSlot == Slot.a ? Slot.b : Slot.a;

    await _stations.clearSlot(station.id, loserSlot);
    await _stations.assignTab(station.id, loserSlot, game.loserTabId);
  }
}
