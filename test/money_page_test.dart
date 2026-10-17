import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:playtab/core/di.dart';
import 'package:playtab/domain/entities/game.dart';
import 'package:playtab/domain/repositories/game_repository.dart';
import 'package:playtab/domain/repositories/payment_repository.dart';
import 'package:playtab/domain/repositories/settings_repository.dart';
import 'package:playtab/domain/repositories/station_repository.dart';
import 'package:playtab/domain/repositories/tab_repository.dart';
import 'package:playtab/domain/usecases/assign_tab_to_slot.dart';
import 'package:playtab/domain/usecases/clear_slot.dart';
import 'package:playtab/domain/usecases/get_available_tabs.dart';
import 'package:playtab/domain/usecases/get_money_report.dart';
import 'package:playtab/domain/usecases/get_stations_with_tabs.dart';
import 'package:playtab/domain/usecases/record_game_result.dart';
import 'package:playtab/domain/usecases/undo_last_game.dart';
import 'package:playtab/presentation/pages/money_page.dart';
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
      ..registerSingleton<GameRepository>(FakeGameRepository(tabs))
      ..registerSingleton<PaymentRepository>(FakePaymentRepository(tabs))
      ..registerSingleton<SettingsRepository>(FakeSettingsRepository())
      ..registerLazySingleton<GetStationsWithTabs>(
          () => GetStationsWithTabs(sl(), sl()))
      ..registerLazySingleton<AssignTabToSlot>(() => AssignTabToSlot(sl()))
      ..registerLazySingleton<ClearSlot>(() => ClearSlot(sl()))
      ..registerLazySingleton<RecordGameResult>(
          () => RecordGameResult(sl(), sl(), sl(), GetAvailableTabs(sl(), sl())))
      ..registerLazySingleton<UndoLastGame>(() => UndoLastGame(sl(), sl()))
      ..registerLazySingleton<GetMoneyReport>(
          () => GetMoneyReport(sl(), sl()));
  });

  testWidgets('money icon on home opens the money screen with stats',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StationsPage()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Money'), findsOneWidget);

    await tester.tap(find.byTooltip('Money'));
    await tester.pumpAndSettle();

    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Collected today'), findsOneWidget);
    expect(find.text('Last 7 days (incl. today)'), findsOneWidget);
    expect(find.text('Last 30 days (incl. today)'), findsOneWidget);
    expect(find.text('Total collected so far'), findsOneWidget);
    expect(find.text('Owed now (open tabs)'), findsOneWidget);
    expect(find.text('0 birr'), findsWidgets);
  });

  testWidgets('owed now shows real debt from open tabs', (tester) async {
    final tabs = sl<TabRepository>() as FakeTabRepository;
    final games = sl<GameRepository>() as FakeGameRepository;
    final winner = await tabs.create();
    final loser = await tabs.create();
    games.games.add(
      Game(
        id: 1,
        stationId: 1,
        winnerTabId: winner.id,
        loserTabId: loser.id,
        playedAt: 0,
        price: 20,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: MoneyPage()));
    await tester.pumpAndSettle();

    expect(find.text('20 birr'), findsOneWidget);
  });
}
