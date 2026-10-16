import '../exceptions.dart';
import '../repositories/station_repository.dart';

class RenameStation {
  RenameStation(this._stations);

  final StationRepository _stations;

  Future<void> call(int stationId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Station name cannot be empty');
    }
    await _stations.rename(stationId, trimmed);
  }
}
