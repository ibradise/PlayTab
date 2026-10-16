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
import 'package:playtab/domain/usecases/get_available_tabs.dart';
import 'package:playtab/domain/usecases/get_tab_owed.dart';
import 'package:playtab/domain/usecases/record_game_result.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteTabRepository tabs;
  late SqfliteStationRepository stations;
  late SqfliteGameRepository games;
  late SqflitePaymentRepository payments;
  late SqfliteSettingsRepository settings;
  late AssignTabToSlot assign;
  late RecordGameResult record;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    tabs = SqfliteTabRepository(db);
    stations = SqfliteStationRepository(db);
    games = SqfliteGameRepository(db);
    payments = SqflitePaymentRepository(db);
    settings = SqfliteSettingsRepository(db);
    assign = AssignTabToSlot(stations);
    record = RecordGameResult(
      stations,
      games,
      settings,
      GetAvailableTabs(tabs, stations),
    );
  });

  tearDown(() => appDb.close());

  test('records one game, frees the loser slot, flags pick when nobody waits',
      () async {
    final a = await tabs.create(label: 'Abebe');
    final b = await tabs.create(label: 'Bekele');
    final station = (await stations.getAll()).first;
    await assign(stationId: station.id, slot: Slot.a, tabId: a.id);
    await assign(stationId: station.id, slot: Slot.b, tabId: b.id);

    final outcome = await record(stationId: station.id, loserTabId: a.id);

    expect(await games.getAll(), hasLength(1));
    expect(outcome.game.winnerTabId, b.id);
    expect(outcome.game.loserTabId, a.id);
    expect(outcome.game.price, 15);
    expect(outcome.needsPick, isTrue);

    final after = (await stations.getAll()).first;
    expect(after.slotATabId, isNull);
    expect(after.slotBTabId, b.id);

    expect(await GetTabOwed(games, payments)(a.id), 15);
  });

  test('auto-places the next player when exactly one is waiting', () async {
    final a = await tabs.create(label: 'Abebe');
    final b = await tabs.create(label: 'Bekele');
    final waiting = await tabs.create(label: 'C');
    final station = (await stations.getAll()).first;
    await assign(stationId: station.id, slot: Slot.a, tabId: a.id);
    await assign(stationId: station.id, slot: Slot.b, tabId: b.id);

    final outcome = await record(stationId: station.id, loserTabId: a.id);

    expect(outcome.needsPick, isFalse);
    expect(outcome.autoPlacedTab?.id, waiting.id);

    final after = (await stations.getAll()).first;
    expect(after.slotATabId, waiting.id);
    expect(after.slotBTabId, b.id);
  });
}
