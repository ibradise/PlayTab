import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:playtab/data/database/app_database.dart';
import 'package:playtab/core/theme_controller.dart';
import 'package:playtab/data/repositories/sqflite_settings_repository.dart';
import 'package:playtab/data/repositories/sqflite_station_repository.dart';
import 'package:playtab/domain/exceptions.dart';
import 'package:playtab/domain/usecases/add_station.dart';
import 'package:playtab/domain/usecases/remove_station.dart';
import 'package:playtab/domain/usecases/rename_station.dart';
import 'package:playtab/domain/usecases/update_price_per_game.dart';

void main() {
  sqfliteFfiInit();

  late AppDatabase appDb;
  late SqfliteSettingsRepository settings;
  late SqfliteStationRepository stations;
  late UpdatePricePerGame updatePrice;
  late AddStation addStation;
  late RenameStation renameStation;
  late RemoveStation removeStation;

  setUp(() async {
    appDb =
        AppDatabase(factory: databaseFactoryFfi, name: inMemoryDatabasePath);
    final db = await appDb.database;
    settings = SqfliteSettingsRepository(db);
    stations = SqfliteStationRepository(db);
    updatePrice = UpdatePricePerGame(settings);
    addStation = AddStation(stations);
    renameStation = RenameStation(stations);
    removeStation = RemoveStation(stations);
  });

  tearDown(() => appDb.close());

  test('price per game updates and rejects non-positive values', () async {
    expect((await settings.get()).pricePerGame, 15);
    await updatePrice(20);
    expect((await settings.get()).pricePerGame, 20);
    await expectLater(
      updatePrice(0),
      throwsA(isA<ValidationException>()),
    );
    expect((await settings.get()).pricePerGame, 20);
  });

  test('adding a station makes it appear in the list', () async {
    expect(await stations.getAll(), hasLength(2));
    final id = await addStation('  TV 3 ');
    expect(await stations.getAll(), hasLength(3));
    expect((await stations.getById(id))?.name, 'TV 3');
    await expectLater(
      addStation('   '),
      throwsA(isA<ValidationException>()),
    );
  });

  test('rename changes the name, remove drops the station', () async {
    final created = await addStation('TV 3');
    await renameStation(created, 'PS 4');
    expect((await stations.getById(created))?.name, 'PS 4');
    await removeStation(created);
    expect(await stations.getById(created), isNull);
    expect(await stations.getAll(), hasLength(2));
  });

  test('theme choice is persisted and round-trips', () async {
    expect((await settings.get()).darkMode, isFalse);

    final controller = ThemeController()
      ..init(settings);
    await Future<void>.delayed(Duration.zero);
    expect(controller.isDark, isFalse);

    await settings.setDarkMode(true);
    final darkController = ThemeController()..init(settings);
    await Future<void>.delayed(Duration.zero);
    expect(darkController.isDark, isTrue);

    // And back.
    await settings.setDarkMode(false);
    expect((await settings.get()).darkMode, isFalse);
  });
}

