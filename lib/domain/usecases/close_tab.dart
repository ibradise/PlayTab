import '../entities/slot.dart';
import '../repositories/station_repository.dart';
import '../repositories/tab_repository.dart';

/// Closes a tab that owes nothing, removing it from any station.
class CloseTab {
  CloseTab(this._tabs, this._stations);

  final TabRepository _tabs;
  final StationRepository _stations;

  Future<void> call(int tabId) async {
    final stations = await _stations.getAll();
    for (final station in stations) {
      if (station.slotATabId == tabId) {
        await _stations.clearSlot(station.id, Slot.a);
      }
      if (station.slotBTabId == tabId) {
        await _stations.clearSlot(station.id, Slot.b);
      }
    }
    await _tabs.close(tabId);
  }
}
