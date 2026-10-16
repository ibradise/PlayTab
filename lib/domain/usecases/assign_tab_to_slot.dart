import '../entities/slot.dart';
import '../repositories/station_repository.dart';

/// Places a tab in a station slot. Enforces the single-station rule by
/// removing the tab from every other slot (other station or the other slot
/// on the same station) first.
class AssignTabToSlot {
  AssignTabToSlot(this._stations);

  final StationRepository _stations;

  Future<void> call({
    required int stationId,
    required Slot slot,
    required int tabId,
  }) async {
    final all = await _stations.getAll();
    for (final station in all) {
      if (station.slotATabId == tabId &&
          !(station.id == stationId && slot == Slot.a)) {
        await _stations.clearSlot(station.id, Slot.a);
      }
      if (station.slotBTabId == tabId &&
          !(station.id == stationId && slot == Slot.b)) {
        await _stations.clearSlot(station.id, Slot.b);
      }
    }
    await _stations.assignTab(stationId, slot, tabId);
  }
}
