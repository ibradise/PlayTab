import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_game_repository.dart';
import 'package:playtab/data/repositories/sqflite_payment_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/usecases/get_open_tabs.dart';
import 'package:playtab/domain/usecases/get_tab_owed.dart';

void main() {
  sqfliteFfiInit();

  test('open tabs pair each tab with its owed amount', () async {
    final appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    final tabs = SqfliteTabRepository(db);
    final games = SqfliteGameRepository(db);
    final payments = SqflitePaymentRepository(db);
    final getOpen = GetOpenTabs(tabs, GetTabOwed(games, payments));

    final t1 = await tabs.create(label: 'Abebe');
    final t2 = await tabs.create();
    await games.insert(
        stationId: 1, winnerTabId: t2.id, loserTabId: t1.id, price: 15);

    final open = await getOpen();
    expect(open.length, 2);
    expect(open.firstWhere((e) => e.tab.id == t1.id).owed, 15);
    expect(open.firstWhere((e) => e.tab.id == t2.id).owed, 0);

    await appDb.close();
  });
}
