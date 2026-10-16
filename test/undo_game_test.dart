import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_game_repository.dart';
import 'package:playtab/data/repositories/sqflite_payment_repository.dart';
import 'package:playtab/data/repositories/sqflite_settings_repository.dart';
import 'package:playtab/data/repositories/sqflite_station_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/entities/slot.dart';
import 'package:playtab/domain/entities/undo_game_result.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/get_available_tabs.dart';
import 'package:playtab/domain/usecases/get_tab_owed.dart';
import 'package:playtab/domain/usecases/record_game_result.dart';
import 'package:playtab/domain/usecases/undo_game.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteTabRepository tabs;
  late SqfliteStationRepository stations;
  late SqfliteGameRepository games;
  late SqflitePaymentRepository payments;
  late AssignTabToSlot assign;
  late RecordGameResult record;
  late UndoGame undo;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    tabs = SqfliteTabRepository(db);
    stations = SqfliteStationRepository(db);
    games = SqfliteGameRepository(db);
    payments = SqflitePaymentRepository(db);
    final settings = SqfliteSettingsRepository(db);
    assign = AssignTabToSlot(stations);
    record = RecordGameResult(
      stations,
      games,
      settings,
      GetAvailableTabs(tabs, stations),
    );
    undo = UndoGame(games, stations);
  });

  tearDown(() => appDb.close());

  test('undo latest game on a station deletes it and restores the slot',
      () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final station = (await stations.getAll()).first;
    await assign(stationId: station.id, slot: Slot.a, tabId: a.id);
    await assign(stationId: station.id, slot: Slot.b, tabId: b.id);

    final outcome = await record(stationId: station.id, loserTabId: a.id);
    expect(await GetTabOwed(games, payments)(a.id), 15);

    final result = await undo(outcome.game.id);

    expect(result.status, UndoStatus.done);
    expect(result.restored, isTrue);
    expect(await games.getAll(), isEmpty);
    expect(await GetTabOwed(games, payments)(a.id), 0);
    expect((await stations.getAll()).first.slotATabId, a.id);
  });

  test('undo blocks when the loser has moved to another station', () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final all = await stations.getAll();
    await assign(stationId: all[0].id, slot: Slot.a, tabId: a.id);
    await assign(stationId: all[0].id, slot: Slot.b, tabId: b.id);

    final outcome = await record(stationId: all[0].id, loserTabId: a.id);
    await assign(stationId: all[1].id, slot: Slot.a, tabId: a.id);

    final result = await undo(outcome.game.id);

    expect(result.status, UndoStatus.conflict);
    expect(result.restored, isFalse);
    expect(await games.getAll(), hasLength(1));
  });

  test('undo an older game deletes it but leaves station slots unchanged',
      () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final station = (await stations.getAll()).first;
    await assign(stationId: station.id, slot: Slot.a, tabId: a.id);
    await assign(stationId: station.id, slot: Slot.b, tabId: b.id);

    final game1 = await games.insert(
        stationId: station.id, winnerTabId: b.id, loserTabId: a.id, price: 15);
    await games.insert(
        stationId: station.id, winnerTabId: a.id, loserTabId: b.id, price: 15);

    final result = await undo(game1.id);

    expect(result.status, UndoStatus.done);
    expect(result.restored, isFalse);
    expect(await games.getAll(), hasLength(1));
    final after = (await stations.getAll()).first;
    expect(after.slotATabId, a.id);
    expect(after.slotBTabId, b.id);
  });
}
