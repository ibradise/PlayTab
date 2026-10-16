import '../entities/slot.dart';
import '../repositories/payment_repository.dart';
import '../repositories/station_repository.dart';
import '../repositories/tab_repository.dart';
import 'get_tab_owed.dart';

/// Records a payment for the tab's full owed amount, then either closes the
/// tab (removing it from any station) or keeps it open.
class MarkPaid {
  MarkPaid(this._tabs, this._payments, this._stations, this._getOwed);

  final TabRepository _tabs;
  final PaymentRepository _payments;
  final StationRepository _stations;
  final GetTabOwed _getOwed;

  Future<void> call({required int tabId, required bool close}) async {
    final owed = await _getOwed(tabId);
    if (owed > 0) {
      await _payments.insert(tabId: tabId, amount: owed);
    }
    if (close) {
      await _removeFromStation(tabId);
      await _tabs.close(tabId);
    }
  }

  Future<void> _removeFromStation(int tabId) async {
    final stations = await _stations.getAll();
    for (final station in stations) {
      if (station.slotATabId == tabId) {
        await _stations.clearSlot(station.id, Slot.a);
      }
      if (station.slotBTabId == tabId) {
        await _stations.clearSlot(station.id, Slot.b);
      }
    }
  }
}
