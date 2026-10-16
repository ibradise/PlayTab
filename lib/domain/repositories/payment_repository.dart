import '../entities/payment.dart';

abstract interface class PaymentRepository {
  Future<void> insert({required int tabId, required int amount});
  Future<List<Payment>> forTab(int tabId);
  Future<int> sumFor(int tabId);
}
