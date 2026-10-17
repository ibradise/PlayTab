import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/data/repositories/sqflite_tab_repository.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteTabRepository tabs;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    tabs = SqfliteTabRepository(await appDb.database);
  });

  tearDown(() => appDb.close());

  test('closed tabs release their number for the next new player', () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final c = await tabs.create(label: 'C');

    expect(a.number, 1);
    expect(b.number, 2);
    expect(c.number, 3);

    await tabs.close(c.id);

    final next = await tabs.create(label: 'D');
    expect(next.number, 3);
  });

  test('the smallest free number is reused (gap in the middle)', () async {
    final a = await tabs.create(label: 'A');
    await tabs.create(label: 'B');
    final c = await tabs.create(label: 'C');
    final d = await tabs.create(label: 'D');

    await tabs.close(a.id); // frees 1
    await tabs.close(c.id); // frees 3

    expect((await tabs.create(label: 'E')).number, 1);

    await tabs.close(d.id); // now 3 is the smallest free
    expect((await tabs.create(label: 'F')).number, 3);
  });

  test('open tabs keep their numbers; numbers of open tabs stay distinct',
      () async {
    final a = await tabs.create(label: 'A');
    final b = await tabs.create(label: 'B');
    final c = await tabs.create(label: 'C');

    expect([a.number, b.number, c.number], [1, 2, 3]);
    final open = await tabs.getOpen();
    expect(open.map((t) => t.number), [1, 2, 3]);
  });

  test('a new player labeled with a name shows #number name', () async {
    final tab = await tabs.create(label: 'Abebe');
    expect(tab.displayLabel, '#1 Abebe');
  });

  test('v1 database migrates: column added, numbers backfilled', () async {
    final name = 'migration_test_${DateTime.now().millisecondsSinceEpoch}.db';
    await databaseFactoryFfi.deleteDatabase(name);

    final oldDb = await databaseFactoryFfi.openDatabase(
      name,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE tabs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            closed_at INTEGER
          )
        ''');
        await db.execute(
          'CREATE TABLE stations (id INTEGER PRIMARY KEY AUTOINCREMENT,'
          ' name TEXT NOT NULL, slot_a_tab_id INTEGER, slot_b_tab_id INTEGER)',
        );
        await db.insert('stations', {'name': 'TV 1'});
        await db.execute(
          'CREATE TABLE games (id INTEGER PRIMARY KEY AUTOINCREMENT,'
          ' station_id INTEGER NOT NULL, winner_tab_id INTEGER NOT NULL,'
          ' loser_tab_id INTEGER NOT NULL, played_at INTEGER NOT NULL,'
          ' price INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE payments (id INTEGER PRIMARY KEY AUTOINCREMENT,'
          ' tab_id INTEGER NOT NULL, amount INTEGER NOT NULL,'
          ' paid_at INTEGER NOT NULL)',
        );
        await db.execute(
          "CREATE TABLE settings (id INTEGER PRIMARY KEY CHECK (id = 1),"
          ' price_per_game INTEGER NOT NULL)',
        );
        await db.insert('settings', {'id': 1, 'price_per_game': 15});
        await db.insert('tabs', {
          'label': 'Old player',
          'status': 'open',
          'created_at': 0,
        });
        await db.insert('tabs', {
          'label': 'Closed player',
          'status': 'closed',
          'created_at': 0,
          'closed_at': 0,
        });
      },
        ),
      );
    await oldDb.close();

    final migrated = AppDatabase(factory: databaseFactoryFfi, name: name);
    final migratedTabs = SqfliteTabRepository(await migrated.database);

    // Backfilled numbers keep working; closed tab #2 releases its number.
    final next = await migratedTabs.create();
    expect(next.number, 2);

    await migrated.close();
    await databaseFactoryFfi.deleteDatabase(name);
  });
}
