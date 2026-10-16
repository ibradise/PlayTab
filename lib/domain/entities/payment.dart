class Payment {
  const Payment({
    required this.id,
    required this.tabId,
    required this.amount,
    required this.paidAt,
  });

  final int id;
  final int tabId;
  final int amount;
  final int paidAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'tab_id': tabId,
        'amount': amount,
        'paid_at': paidAt,
      };

  factory Payment.fromMap(Map<String, Object?> map) => Payment(
        id: map['id'] as int,
        tabId: map['tab_id'] as int,
        amount: map['amount'] as int,
        paidAt: map['paid_at'] as int,
      );
}
