import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_game_repository.dart';
import 'package:playtab/data/repositories/sqflite_payment_repository.dart';
import 'package:playtab/data/repositories/sqflite_settings_repository.dart';
import 'package:playtab/data/repositories/sqflite_station_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/entities/slot.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/get_tab_owed.dart';
import 'package:playtab/domain/usecases/mark_paid.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteTabRepository tabs;
  late SqfliteStationRepository stations;
  late SqfliteGameRepository games;
  late SqflitePaymentRepository payments;
  late MarkPaid markPaid;
  late GetTabOwed owed;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    tabs = SqfliteTabRepository(db);
    stations = SqfliteStationRepository(db);
    games = SqfliteGameRepository(db);
    payments = SqflitePaymentRepository(db);
    final settings = SqfliteSettingsRepository(db);
    owed = GetTabOwed(games, payments);
    markPaid = MarkPaid(tabs, payments, stations, owed);
    // unused settings kept for parity with DI
    expect(settings, isNotNull);
  });

  tearDown(() => appDb.close());

  test('close: records payment, clears owed, removes from station, closes tab',
      () async {
    final a = await tabs.create(label: 'Abebe');
    final b = await tabs.create(label: 'Bekele');
    final station = (await stations.getAll()).first;
    final assign = AssignTabToSlot(stations);
    await assign(stationId: station.id, slot: Slot.a, tabId: a.id);
    await assign(stationId: station.id, slot: Slot.b, tabId: b.id);
    await games.insert(
        stationId: station.id, winnerTabId: b.id, loserTabId: a.id, price: 15);

    await markPaid(tabId: a.id, close: true);

    expect(await owed(a.id), 0);
    expect((await tabs.getById(a.id))!.isOpen, isFalse);
    expect((await tabs.getOpen()).map((t) => t.id), isNot(contains(a.id)));

    final after = (await stations.getAll()).first;
    expect(after.hasTab(a.id), isFalse);
  });

  test('keep open: records payment, owed is 0, tab stays open on station',
      () async {
    final a = await tabs.create(label: 'Abebe');
    final b = await tabs.create(label: 'Bekele');
    final station = (await stations.getAll()).first;
    final assign = AssignTabToSlot(stations);
    await assign(stationId: station.id, slot: Slot.a, tabId: a.id);
    await assign(stationId: station.id, slot: Slot.b, tabId: b.id);
    await games.insert(
        stationId: station.id, winnerTabId: b.id, loserTabId: a.id, price: 15);

    await markPaid(tabId: a.id, close: false);

    expect(await owed(a.id), 0);
    expect((await tabs.getById(a.id))!.isOpen, isTrue);
    expect((await stations.getAll()).first.hasTab(a.id), isTrue);
  });
}
