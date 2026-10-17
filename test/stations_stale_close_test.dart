import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:playtab/core/di.dart';
import 'package:playtab/domain/entities/slot.dart';
import 'package:playtab/domain/repositories/game_repository.dart';
import 'package:playtab/domain/repositories/payment_repository.dart';
import 'package:playtab/domain/repositories/settings_repository.dart';
import 'package:playtab/domain/repositories/station_repository.dart';
import 'package:playtab/domain/repositories/tab_repository.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/clear_slot.dart';
import 'package:playtab/domain/usecases/get_available_tabs.dart';
import 'package:playtab/domain/usecases/get_stations_with_tabs.dart';
import 'package:playtab/domain/usecases/record_game_result.dart';
import 'package:playtab/domain/usecases/undo_last_game.dart';
import 'package:playtab/presentation/bloc/stations/stations_bloc.dart';
import 'package:playtab/presentation/pages/stations_page.dart';

import '_fakes.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    final tabs = FakeTabRepository();
    final stations = FakeStationRepository();
    sl
      ..registerSingleton<TabRepository>(tabs)
      ..registerSingleton<StationRepository>(stations)
      ..registerSingleton<GameRepository>(FakeGameRepository())
      ..registerSingleton<PaymentRepository>(FakePaymentRepository())
      ..registerSingleton<SettingsRepository>(FakeSettingsRepository())
      ..registerLazySingleton<GetStationsWithTabs>(
          () => GetStationsWithTabs(sl(), sl()))
      ..registerLazySingleton<AssignTabToSlot>(() => AssignTabToSlot(sl()))
      ..registerLazySingleton<ClearSlot>(() => ClearSlot(sl()))
      ..registerLazySingleton<RecordGameResult>(
          () => RecordGameResult(sl(), sl(), sl(), GetAvailableTabs(sl(), sl())))
      ..registerLazySingleton<UndoLastGame>(() => UndoLastGame(sl(), sl()));
  });

  testWidgets(
      'tapping a stale lost button keeps the screen alive and refreshes',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StationsPage()));
    await tester.pumpAndSettle();

    final bloc =
        tester.element(find.text('PS Zone')).read<StationsBloc>();
    final tabsRepo =
        sl<TabRepository>() as FakeTabRepository;
    final stationRepo = sl<StationRepository>() as FakeStationRepository;

    final a = await tabsRepo.create(label: 'A');
    final b = await tabsRepo.create(label: 'B');
    bloc.add(TabAssigned(stationId: 1, slot: Slot.a, tabId: a.id));
    await tester.pumpAndSettle();
    bloc.add(TabAssigned(stationId: 1, slot: Slot.b, tabId: b.id));
    await tester.pumpAndSettle();

    expect(find.text('#1 A lost'), findsOneWidget);
    expect(find.text('#2 B lost'), findsOneWidget);

    // Close tab A the way the tab-detail flow does (removes it from its
    // slot in the database) WITHOUT reloading the home screen.
    await tabsRepo.close(a.id);
    await stationRepo.clearSlot(1, Slot.a);

    await tester.tap(find.text('#1 A lost'));
    await tester.pumpAndSettle();

    // The problem is reported instead of killing the screen…
    expect(
      find.text('Both slots must be filled before recording a game'),
      findsOneWidget,
    );
    // …and the station card refreshed: the closed player is gone.
    expect(find.text('TV 1'), findsOneWidget);
    expect(find.text('empty slot'), findsWidgets);
  });
}
