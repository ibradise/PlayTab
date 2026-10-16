import '../entities/tab.dart';
import '../repositories/station_repository.dart';
import '../repositories/tab_repository.dart';

/// Open tabs that are not currently placed on any station (Pick player list).
class GetAvailableTabs {
  GetAvailableTabs(this._tabs, this._stations);

  final TabRepository _tabs;
  final StationRepository _stations;

  Future<List<Tab>> call() async {
    final open = await _tabs.getOpen();
    final stations = await _stations.getAll();
    final placed = <int>{};
    for (final station in stations) {
      if (station.slotATabId != null) placed.add(station.slotATabId!);
      if (station.slotBTabId != null) placed.add(station.slotBTabId!);
    }
    return open.where((t) => !placed.contains(t.id)).toList();
  }
}
