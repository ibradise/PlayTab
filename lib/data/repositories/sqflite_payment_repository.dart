import 'package:sqflite/sqflite.dart';

import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

class SqflitePaymentRepository implements PaymentRepository {
  SqflitePaymentRepository(this._db);

  final Database _db;

  @override
  Future<void> insert({required int tabId, required int amount}) =>
      _db.insert('payments', {
        'tab_id': tabId,
        'amount': amount,
        'paid_at': DateTime.now().millisecondsSinceEpoch,
      });

  @override
  Future<List<Payment>> forTab(int tabId) async {
    final rows = await _db.query(
      'payments',
      where: 'tab_id = ?',
      whereArgs: [tabId],
      orderBy: 'id',
    );
    return rows.map(Payment.fromMap).toList();
  }

  @override
  Future<int> sumFor(int tabId) async {
    final rows = await _db.query(
      'payments',
      columns: ['amount'],
      where: 'tab_id = ?',
      whereArgs: [tabId],
    );
    return rows.fold<int>(0, (sum, r) => sum + (r['amount'] as int));
  }
}
