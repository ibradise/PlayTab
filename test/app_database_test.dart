import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';

void main() {
  sqfliteFfiInit();

  test('creates schema and seeds 2 stations + default price 15', () async {
    final appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;

    final stations = await db.query('stations');
    expect(stations.length, 2);
    expect(stations.map((s) => s['name']), containsAll(['TV 1', 'TV 2']));

    final settings = await db.query('settings');
    expect(settings.length, 1);
    expect(settings.first['price_per_game'], 15);

    await appDb.close();
  });
}
