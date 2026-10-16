import '../entities/slot.dart';
import '../repositories/station_repository.dart';

class ClearSlot {
  ClearSlot(this._stations);

  final StationRepository _stations;

  Future<void> call({required int stationId, required Slot slot}) =>
      _stations.clearSlot(stationId, slot);
}
