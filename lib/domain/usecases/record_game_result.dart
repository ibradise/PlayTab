import '../entities/record_game_outcome.dart';
import '../entities/slot.dart';
import '../entities/tab.dart';
import '../repositories/game_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/station_repository.dart';
import 'get_available_tabs.dart';

/// Records one finished game on a station: the given tab lost, the other tab
/// on the station won. Frees the loser slot and auto-places the next player
/// when exactly one tab is waiting.
class RecordGameResult {
  RecordGameResult(
    this._stations,
    this._games,
    this._settings,
    this._availableTabs,
  );

  final StationRepository _stations;
  final GameRepository _games;
  final SettingsRepository _settings;
  final GetAvailableTabs _availableTabs;

  Future<RecordGameOutcome> call({
    required int stationId,
    required int loserTabId,
  }) async {
    final station = await _stations.getById(stationId);
    if (station == null) {
      throw StateError('Station not found');
    }
    if (!station.isFull) {
      throw StateError('Both slots must be filled before recording a game');
    }

    final Slot loserSlot;
    final int winnerTabId;
    if (station.slotATabId == loserTabId) {
      loserSlot = Slot.a;
      winnerTabId = station.slotBTabId!;
    } else if (station.slotBTabId == loserTabId) {
      loserSlot = Slot.b;
      winnerTabId = station.slotATabId!;
    } else {
      throw StateError('Loser is not playing on this station');
    }

    // Waiting players are open tabs not currently on any station. Computed
    // before clearing the slot so the loser is not counted as waiting.
    final waiting = await _availableTabs();
    final price = (await _settings.get()).pricePerGame;

    final game = await _games.insert(
      stationId: stationId,
      winnerTabId: winnerTabId,
      loserTabId: loserTabId,
      price: price,
    );

    await _stations.clearSlot(stationId, loserSlot);

    Tab? autoPlaced;
    if (waiting.length == 1) {
      autoPlaced = waiting.first;
      await _stations.assignTab(stationId, loserSlot, autoPlaced.id);
    }

    return RecordGameOutcome(
      game: game,
      freedSlot: loserSlot,
      autoPlacedTab: autoPlaced,
    );
  }
}
