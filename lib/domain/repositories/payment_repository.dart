import '../entities/payment.dart';

abstract interface class PaymentRepository {
  Future<void> insert({required int tabId, required int amount});
  Future<List<Payment>> forTab(int tabId);
  Future<int> sumFor(int tabId);

  /// Total birr collected at or after [fromEpochMs].
  Future<int> sumSince(int fromEpochMs);

  /// Total birr collected all time.
  Future<int> sumAll();

  /// Total birr collected from tabs that are currently open.
  Future<int> sumForOpenTabs();
}
