class MoneyReport {
  const MoneyReport({
    required this.collectedToday,
    required this.collectedLast7Days,
    required this.collectedLast30Days,
    required this.averagePerDay7,
    required this.averagePerDay30,
    required this.totalCollected,
    required this.owedNow,
  });

  final int collectedToday;
  final int collectedLast7Days;
  final int collectedLast30Days;

  /// Birr per day averaged over the window (zero days count as zero).
  final double averagePerDay7;
  final double averagePerDay30;

  final int totalCollected;

  /// Birr lost-but-unpaid on tabs that are still open.
  final int owedNow;
}
