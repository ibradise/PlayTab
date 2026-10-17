import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_game_repository.dart';
import 'package:playtab/data/repositories/sqflite_payment_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/usecases/get_money_report.dart';

void main() {
  sqfliteFfiInit();

  test('money report: empty, then windows, averages, and owed-now math',
      () async {
    final appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    final payments = SqflitePaymentRepository(db);
    final games = SqfliteGameRepository(db);
    final report = GetMoneyReport(payments, games);

    // Empty database reports zeros.
    final empty = await report();
    expect(empty.collectedToday, 0);
    expect(empty.collectedLast7Days, 0);
    expect(empty.collectedLast30Days, 0);
    expect(empty.totalCollected, 0);
    expect(empty.averagePerDay7, 0);
    expect(empty.averagePerDay30, 0);
    expect(empty.owedNow, 0);

    // Seed payments at known offsets.
    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final today = todayStart + 3 * 3600000;
    final yesterday = todayStart - 5 * 3600000;
    final lastWeek = todayStart - 10 * 24 * 3600000;
    final lastMonth = todayStart - 40 * 24 * 3600000;

    Future<void> pay(int tabId, int amount, int at) async {
      await payments.insert(tabId: tabId, amount: amount);
      final rows =
          await db.query('payments', columns: ['id'], orderBy: 'id DESC', limit: 1);
      await db.update('payments', {'paid_at': at},
          where: 'id = ?', whereArgs: [rows.first['id']]);
    }

    // today 10 + 5, yesterday 8, last week 100, last month 200 (= 323 total).
    // Tab ids 21–25 don't collide with any tab we create later.
    await pay(21, 10, today);
    await pay(22, 200, lastMonth);
    await pay(23, 100, lastWeek);
    await pay(24, 8, yesterday);
    await pay(25, 5, today);

    final r = await report();

    expect(r.collectedToday, 15);
    // 7d = today + previous 6 days: 15 + 8 = 23.
    expect(r.collectedLast7Days, 23);
    // 30d = today + previous 29 days: 15 + 8 + 100 = 123 (only the
    // 40-day-old payment lands outside).
    expect(r.collectedLast30Days, 123);
    expect(r.totalCollected, 323);
    expect(r.averagePerDay7, closeTo(23 / 7, 0.001));
    expect(r.averagePerDay30, closeTo(123 / 30, 0.001));
    expect(r.owedNow, 0);

    // Open tabs still owing: 20 lost, 0 paid. Closed tab's 50 is not owed.
    final openTab = await SqfliteTabRepository(db).create();
    final openTab2 = await SqfliteTabRepository(db).create();
    final closedTab = await SqfliteTabRepository(db).create(label: 'old');
    await SqfliteTabRepository(db).close(closedTab.id);

    await games.insert(
        stationId: 1, winnerTabId: openTab.id, loserTabId: openTab2.id, price: 20);
    await games.insert(
        stationId: 1, winnerTabId: openTab.id, loserTabId: closedTab.id, price: 50);

    final finalReport = await report();
    expect(finalReport.owedNow, 20);

    await appDb.close();
  });
}
