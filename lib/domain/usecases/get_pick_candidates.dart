import '../entities/station.dart';
import '../entities/tab_candidate.dart';
import '../repositories/station_repository.dart';
import '../repositories/tab_repository.dart';

/// All open tabs for the pick list. Waiting tabs come first; tabs placed on
/// another station follow (placing them somewhere else means a move).
class GetPickCandidates {
  GetPickCandidates(this._tabs, this._stations);

  final TabRepository _tabs;
  final StationRepository _stations;

  Future<List<TabCandidate>> call() async {
    final open = await _tabs.getOpen();
    final stations = await _stations.getAll();

    final candidates = <TabCandidate>[];
    for (final tab in open) {
      Station? current;
      for (final station in stations) {
        if (station.hasTab(tab.id)) {
          current = station;
          break;
        }
      }
      candidates.add(TabCandidate(tab: tab, currentStation: current));
    }

    candidates.sort((a, b) {
      if (a.onStation != b.onStation) return a.onStation ? 1 : -1;
      return a.tab.id.compareTo(b.tab.id);
    });
    return candidates;
  }
}
