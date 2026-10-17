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

  @override
  Future<int> sumSince(int fromEpochMs) async {
    final row = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total'
      ' FROM payments WHERE paid_at >= ?',
      [fromEpochMs],
    );
    return row.first['total'] as int;
  }

  @override
  Future<int> sumAll() async {
    final row = await _db
        .rawQuery('SELECT COALESCE(SUM(amount), 0) AS total FROM payments');
    return row.first['total'] as int;
  }

  @override
  Future<int> sumForOpenTabs() async {
    final row = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM payments'
      " WHERE tab_id IN (SELECT id FROM tabs WHERE status = 'open')",
    );
    return row.first['total'] as int;
  }
}
