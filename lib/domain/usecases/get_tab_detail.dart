import '../entities/tab_detail.dart';
import '../repositories/settings_repository.dart';
import '../repositories/tab_repository.dart';
import 'get_head_to_head.dart';
import 'get_tab_owed.dart';
import 'get_tab_stats.dart';

class GetTabDetail {
  GetTabDetail(
    this._tabs,
    this._getOwed,
    this._getStats,
    this._getHeadToHead,
    this._settings,
  );

  final TabRepository _tabs;
  final GetTabOwed _getOwed;
  final GetTabStats _getStats;
  final GetHeadToHead _getHeadToHead;
  final SettingsRepository _settings;

  Future<TabDetail?> call(int tabId) async {
    final tab = await _tabs.getById(tabId);
    if (tab == null) return null;
    return TabDetail(
      tab: tab,
      owed: await _getOwed(tabId),
      stats: await _getStats(tabId),
      pricePerGame: (await _settings.get()).pricePerGame,
      headToHead: await _getHeadToHead(tabId),
    );
  }
}
