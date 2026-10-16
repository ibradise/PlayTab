import '../entities/tab_with_owed.dart';
import '../repositories/tab_repository.dart';
import 'get_tab_owed.dart';

/// Open tabs paired with the amount each currently owes.
class GetOpenTabs {
  GetOpenTabs(this._tabs, this._getOwed);

  final TabRepository _tabs;
  final GetTabOwed _getOwed;

  Future<List<TabWithOwed>> call() async {
    final open = await _tabs.getOpen();
    final result = <TabWithOwed>[];
    for (final tab in open) {
      result.add(TabWithOwed(tab: tab, owed: await _getOwed(tab.id)));
    }
    return result;
  }
}
