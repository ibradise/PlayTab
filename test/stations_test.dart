import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_station_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/entities/slot.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/get_available_tabs.dart';
import 'package:playtab/domain/usecases/get_stations_with_tabs.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteStationRepository stations;
  late SqfliteTabRepository tabs;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    stations = SqfliteStationRepository(db);
    tabs = SqfliteTabRepository(db);
  });

  tearDown(() => appDb.close());

  test('a tab can be on only one station at a time (moves it)', () async {
    final assign = AssignTabToSlot(stations);
    final tab = await tabs.create(label: 'Abebe');
    final all = await stations.getAll();
    final s1 = all[0].id;
    final s2 = all[1].id;

    await assign(stationId: s1, slot: Slot.a, tabId: tab.id);
    await assign(stationId: s2, slot: Slot.b, tabId: tab.id);

    final after = await stations.getAll();
    final one = after.firstWhere((s) => s.id == s1);
    final two = after.firstWhere((s) => s.id == s2);
    expect(one.slotATabId, isNull);
    expect(two.slotBTabId, tab.id);
  });

  test('station tabs resolve and available excludes placed tabs', () async {
    final assign = AssignTabToSlot(stations);
    final tab = await tabs.create(label: 'Abebe');
    final all = await stations.getAll();
    await assign(stationId: all[0].id, slot: Slot.a, tabId: tab.id);

    final withTabs = await GetStationsWithTabs(stations, tabs)();
    expect(withTabs[0].slotA?.label, 'Abebe');

    final available = await GetAvailableTabs(tabs, stations)();
    expect(available.map((t) => t.id), isNot(contains(tab.id)));
  });
}
