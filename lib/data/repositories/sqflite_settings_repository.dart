import 'package:sqflite/sqflite.dart';

import '../../domain/entities/app_setting.dart';
import '../../domain/repositories/settings_repository.dart';

class SqfliteSettingsRepository implements SettingsRepository {
  SqfliteSettingsRepository(this._db);

  final Database _db;

  @override
  Future<AppSetting> get() async {
    final rows = await _db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [AppSetting.settingsRowId],
      limit: 1,
    );
    return AppSetting.fromMap(rows.first);
  }

  @override
  Future<void> setPricePerGame(int price) => _db.update(
        'settings',
        {'price_per_game': price},
        where: 'id = ?',
        whereArgs: [AppSetting.settingsRowId],
      );

  @override
  Future<void> setDarkMode(bool dark) => _db.update(
        'settings',
        {'dark_mode': dark ? 1 : 0},
        where: 'id = ?',
        whereArgs: [AppSetting.settingsRowId],
      );
}
