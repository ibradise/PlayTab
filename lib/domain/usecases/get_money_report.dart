import '../entities/money_report.dart';
import '../repositories/game_repository.dart';
import '../repositories/payment_repository.dart';

class GetMoneyReport {
  GetMoneyReport(this._payments, this._games);

  final PaymentRepository _payments;
  final GameRepository _games;

  Future<MoneyReport> call() async {
    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final weekStart = todayStart - const Duration(days: 6).inMilliseconds;
    final monthStart = todayStart - const Duration(days: 29).inMilliseconds;

    final today = await _payments.sumSince(todayStart);
    final week = await _payments.sumSince(weekStart);
    final month = await _payments.sumSince(monthStart);
    final total = await _payments.sumAll();

    final lostToOpen = await _games.sumLostPricesForOpenTabs();
    final paidByOpen = await _payments.sumForOpenTabs();

    return MoneyReport(
      collectedToday: today,
      collectedLast7Days: week,
      collectedLast30Days: month,
      averagePerDay7: week / 7,
      averagePerDay30: month / 30,
      totalCollected: total,
      owedNow: lostToOpen - paidByOpen,
    );
  }
}
