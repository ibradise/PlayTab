import '../repositories/station_repository.dart';

class RemoveStation {
  RemoveStation(this._stations);

  final StationRepository _stations;

  Future<void> call(int stationId) => _stations.delete(stationId);
}
