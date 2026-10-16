import '../exceptions.dart';
import '../repositories/settings_repository.dart';

class UpdatePricePerGame {
  UpdatePricePerGame(this._settings);

  final SettingsRepository _settings;

  Future<void> call(int price) async {
    if (price < 1) {
      throw const ValidationException('Price must be at least 1 birr');
    }
    await _settings.setPricePerGame(price);
  }
}
