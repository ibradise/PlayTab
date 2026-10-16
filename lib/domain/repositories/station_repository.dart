import '../entities/slot.dart';
import '../entities/station.dart';

abstract interface class StationRepository {
  Future<List<Station>> getAll();
  Future<Station?> getById(int id);
  Future<int> create(String name);
  Future<void> rename(int id, String name);
  Future<void> delete(int id);
  Future<void> assignTab(int stationId, Slot slot, int tabId);
  Future<void> clearSlot(int stationId, Slot slot);
}
