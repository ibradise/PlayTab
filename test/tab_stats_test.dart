import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_game_repository.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';
import 'package:playtab/domain/usecases/get_head_to_head.dart';
import 'package:playtab/domain/usecases/get_tab_stats.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteTabRepository tabs;
  late SqfliteGameRepository games;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    tabs = SqfliteTabRepository(db);
    games = SqfliteGameRepository(db);
  });

  tearDown(() => appDb.close());

  test('tab stats derive played/won/lost from games', () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final c = await tabs.create(label: 'C');

    await games.insert(
        stationId: 1, winnerTabId: a.id, loserTabId: b.id, price: 15);
    await games.insert(
        stationId: 1, winnerTabId: b.id, loserTabId: a.id, price: 15);
    await games.insert(
        stationId: 1, winnerTabId: c.id, loserTabId: a.id, price: 15);

    final stats = await GetTabStats(games)(a.id);
    expect(stats.played, 3);
    expect(stats.won, 1);
    expect(stats.lost, 2);
  });

  test('head-to-head groups wins and losses per opponent', () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final c = await tabs.create(label: 'C');

    await games.insert(
        stationId: 1, winnerTabId: a.id, loserTabId: b.id, price: 15);
    await games.insert(
        stationId: 1, winnerTabId: b.id, loserTabId: a.id, price: 15);
    await games.insert(
        stationId: 1, winnerTabId: c.id, loserTabId: a.id, price: 15);

    final h2h = await GetHeadToHead(games, tabs)(a.id);
    expect(h2h.length, 2);

    final vsB = h2h.firstWhere((e) => e.other.id == b.id);
    expect(vsB.wonAgainst, 1);
    expect(vsB.lostAgainst, 1);

    final vsC = h2h.firstWhere((e) => e.other.id == c.id);
    expect(vsC.wonAgainst, 0);
    expect(vsC.lostAgainst, 1);
  });
}
