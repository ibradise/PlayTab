import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_game_repository.dart';
import 'package:playtab/data/repositories/sqflite_payment_repository.dart';
import 'package:playtab/domain/usecases/get_tab_owed.dart';

void main() {
  sqfliteFfiInit();

  test('owed equals lost games minus payments', () async {
    final appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    final games = SqfliteGameRepository(db);
    final payments = SqflitePaymentRepository(db);
    final getOwed = GetTabOwed(games, payments);

    await games.insert(stationId: 1, winnerTabId: 2, loserTabId: 1, price: 15);
    await games.insert(stationId: 1, winnerTabId: 3, loserTabId: 1, price: 15);
    expect(await getOwed(1), 30);

    await payments.insert(tabId: 1, amount: 15);
    expect(await getOwed(1), 15);

    await appDb.close();
  });
}
