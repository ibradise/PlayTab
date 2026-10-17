import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:playtab/core/di.dart';
import 'package:playtab/core/theme_controller.dart';
import 'package:playtab/domain/repositories/game_repository.dart';
import 'package:playtab/domain/repositories/payment_repository.dart';
import 'package:playtab/domain/repositories/settings_repository.dart';
import 'package:playtab/domain/repositories/station_repository.dart';
import 'package:playtab/domain/repositories/tab_repository.dart';
import 'package:playtab/domain/usecases/add_station.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/clear_slot.dart';
import 'package:playtab/domain/usecases/get_available_tabs.dart';
import 'package:playtab/domain/usecases/get_stations_with_tabs.dart';
import 'package:playtab/domain/usecases/record_game_result.dart';
import 'package:playtab/domain/usecases/remove_station.dart';
import 'package:playtab/domain/usecases/rename_station.dart';
import 'package:playtab/domain/usecases/undo_last_game.dart';
import 'package:playtab/domain/usecases/update_price_per_game.dart';
import 'package:playtab/presentation/pages/stations_page.dart';

import '_fakes.dart';

void _registerDeps() {
  final tabs = FakeTabRepository();
  final stations = FakeStationRepository();
  final games = FakeGameRepository();
  final payments = FakePaymentRepository();
  final settings = FakeSettingsRepository();

  sl
    ..registerSingleton<TabRepository>(tabs)
    ..registerSingleton<StationRepository>(stations)
    ..registerSingleton<GameRepository>(games)
    ..registerSingleton<PaymentRepository>(payments)
    ..registerSingleton<SettingsRepository>(settings)
    ..registerSingleton<ThemeController>(ThemeController())
    ..registerLazySingleton<GetStationsWithTabs>(
        () => GetStationsWithTabs(sl(), sl()))
    ..registerLazySingleton<AssignTabToSlot>(() => AssignTabToSlot(sl()))
    ..registerLazySingleton<ClearSlot>(() => ClearSlot(sl()))
    ..registerLazySingleton<RecordGameResult>(
        () => RecordGameResult(sl(), sl(), sl(), GetAvailableTabs(sl(), sl())))
    ..registerLazySingleton<UndoLastGame>(() => UndoLastGame(sl(), sl()))
    ..registerLazySingleton<UpdatePricePerGame>(() => UpdatePricePerGame(sl()))
    ..registerLazySingleton<AddStation>(() => AddStation(sl()))
    ..registerLazySingleton<RenameStation>(() => RenameStation(sl()))
    ..registerLazySingleton<RemoveStation>(() => RemoveStation(sl()));
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    _registerDeps();
  });

  testWidgets('settings: rename, add, and returning home stays interactive',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StationsPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Open settings.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Rename TV 1 -> TV X (the flow that froze the home page afterwards).
    await tester.tap(find.byTooltip('Rename').first);
    await tester.pumpAndSettle();
    expect(find.text('Rename station'), findsOneWidget);

    final dialogTextField =
        find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
    final dialogSave = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Save'),
    );

    await tester.enterText(dialogTextField, 'TV X');
    await tester.tap(dialogSave);
    await tester.pumpAndSettle();

    final renameError = tester.takeException();
    expect(renameError, isNull);

    // Go back home.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('PS Zone'), findsOneWidget);

    // Freeze check: settings must open again from home.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    final thirdError = tester.takeException();
    expect(thirdError, isNull);

    // Add a TV via the dialog (the flow that showed the red screen).
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add station'), findsOneWidget);

    await tester.enterText(dialogTextField, 'TV 3');
    await tester.tap(dialogSave);
    await tester.pumpAndSettle();

    final addError = tester.takeException();
    expect(addError, isNull);

    // The new TV should be listed after the dialog closes.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('TV 3'), findsOneWidget);
  });
}
