import '../entities/app_setting.dart';

abstract interface class SettingsRepository {
  Future<AppSetting> get();
  Future<void> setPricePerGame(int price);
}
