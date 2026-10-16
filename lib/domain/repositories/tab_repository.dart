import '../entities/tab.dart';

abstract interface class TabRepository {
  Future<Tab> create({String? label});
  Future<List<Tab>> getOpen();
  Future<Tab?> getById(int id);
  Future<void> updateLabel(int id, String label);
  Future<void> close(int id);
}
