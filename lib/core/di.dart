import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../data/database/app_database.dart';
import '../data/repositories/sqflite_game_repository.dart';
import '../data/repositories/sqflite_payment_repository.dart';
import '../data/repositories/sqflite_settings_repository.dart';
import '../data/repositories/sqflite_station_repository.dart';
import '../data/repositories/sqflite_tab_repository.dart';
import '../domain/repositories/game_repository.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/station_repository.dart';
import '../domain/repositories/tab_repository.dart';
import '../domain/usecases/assign_tab_to_slot.dart';
import '../domain/usecases/clear_slot.dart';
import '../domain/usecases/close_tab.dart';
import '../domain/usecases/create_tab.dart';
import '../domain/usecases/get_available_tabs.dart';
import '../domain/usecases/get_open_tabs.dart';
import '../domain/usecases/get_stations_with_tabs.dart';
import '../domain/usecases/get_tab_detail.dart';
import '../domain/usecases/get_tab_owed.dart';
import '../domain/usecases/mark_paid.dart';
import '../domain/usecases/record_game_result.dart';
import '../domain/usecases/undo_last_game.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies({Database? database}) async {
  final db = database ?? await AppDatabase.instance.database;
  sl.registerSingleton<Database>(db);

  sl.registerLazySingleton<TabRepository>(() => SqfliteTabRepository(sl()));
  sl.registerLazySingleton<StationRepository>(
      () => SqfliteStationRepository(sl()));
  sl.registerLazySingleton<GameRepository>(() => SqfliteGameRepository(sl()));
  sl.registerLazySingleton<PaymentRepository>(
      () => SqflitePaymentRepository(sl()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SqfliteSettingsRepository(sl()));

  sl.registerLazySingleton<GetTabOwed>(() => GetTabOwed(sl(), sl()));
  sl.registerLazySingleton<GetOpenTabs>(() => GetOpenTabs(sl(), sl()));
  sl.registerLazySingleton<GetStationsWithTabs>(
      () => GetStationsWithTabs(sl(), sl()));
  sl.registerLazySingleton<GetAvailableTabs>(() => GetAvailableTabs(sl(), sl()));
  sl.registerLazySingleton<CreateTab>(() => CreateTab(sl()));
  sl.registerLazySingleton<AssignTabToSlot>(() => AssignTabToSlot(sl()));
  sl.registerLazySingleton<ClearSlot>(() => ClearSlot(sl()));
  sl.registerLazySingleton<RecordGameResult>(
      () => RecordGameResult(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton<UndoLastGame>(() => UndoLastGame(sl(), sl()));
  sl.registerLazySingleton<GetTabDetail>(
      () => GetTabDetail(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton<MarkPaid>(() => MarkPaid(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton<CloseTab>(() => CloseTab(sl(), sl()));
}
