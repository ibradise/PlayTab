import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_station_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/entities/slot.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/get_pick_candidates.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteTabRepository tabs;
  late SqfliteStationRepository stations;
  late AssignTabToSlot assign;
  late GetPickCandidates candidates;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    tabs = SqfliteTabRepository(db);
    stations = SqfliteStationRepository(db);
    assign = AssignTabToSlot(stations);
    candidates = GetPickCandidates(tabs, stations);
  });

  tearDown(() => appDb.close());

  test('waiting tabs come first, placed tabs carry their current station',
      () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final waiting = await tabs.create(label: 'W');
    final all = await stations.getAll();
    await assign(stationId: all[0].id, slot: Slot.a, tabId: a.id);
    await assign(stationId: all[0].id, slot: Slot.b, tabId: b.id);

    final result = await candidates();

    expect(result, hasLength(3));
    expect(result.first.tab.id, waiting.id);
    expect(result.first.onStation, isFalse);

    final placed = result.skip(1).toList();
    expect(placed.map((c) => c.tab.id), containsAll([a.id, b.id]));
    expect(placed.every((c) => c.onStation), isTrue);
    expect(placed.first.currentStation!.id, all[0].id);
    expect(placed.first.currentStation!.name, 'TV 1');
  });
}
