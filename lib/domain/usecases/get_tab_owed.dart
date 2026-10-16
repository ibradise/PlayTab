import '../repositories/game_repository.dart';
import '../repositories/payment_repository.dart';

/// Amount owed by a tab = sum of prices of games it lost minus its payments.
class GetTabOwed {
  GetTabOwed(this._games, this._payments);

  final GameRepository _games;
  final PaymentRepository _payments;

  Future<int> call(int tabId) async {
    final lost = await _games.lostPricesFor(tabId);
    final lostTotal = lost.fold<int>(0, (sum, price) => sum + price);
    final paid = await _payments.sumFor(tabId);
    return lostTotal - paid;
  }
}
