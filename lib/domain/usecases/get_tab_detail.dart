import '../entities/tab_detail.dart';
import '../repositories/game_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/tab_repository.dart';
import 'get_tab_owed.dart';

class GetTabDetail {
  GetTabDetail(this._tabs, this._games, this._settings, this._getOwed);

  final TabRepository _tabs;
  final GameRepository _games;
  final SettingsRepository _settings;
  final GetTabOwed _getOwed;

  Future<TabDetail?> call(int tabId) async {
    final tab = await _tabs.getById(tabId);
    if (tab == null) return null;
    final losses = (await _games.lostPricesFor(tabId)).length;
    final owed = await _getOwed(tabId);
    final price = (await _settings.get()).pricePerGame;
    return TabDetail(
      tab: tab,
      owed: owed,
      losses: losses,
      pricePerGame: price,
    );
  }
}
