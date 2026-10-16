import '../entities/station_with_tabs.dart';
import '../repositories/station_repository.dart';
import '../repositories/tab_repository.dart';

/// Stations with the tabs currently sitting in each slot resolved.
class GetStationsWithTabs {
  GetStationsWithTabs(this._stations, this._tabs);

  final StationRepository _stations;
  final TabRepository _tabs;

  Future<List<StationWithTabs>> call() async {
    final stations = await _stations.getAll();
    final result = <StationWithTabs>[];
    for (final station in stations) {
      final a = station.slotATabId == null
          ? null
          : await _tabs.getById(station.slotATabId!);
      final b = station.slotBTabId == null
          ? null
          : await _tabs.getById(station.slotBTabId!);
      result.add(StationWithTabs(station: station, slotA: a, slotB: b));
    }
    return result;
  }
}
