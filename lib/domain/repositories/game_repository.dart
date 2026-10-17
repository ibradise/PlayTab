import '../entities/game.dart';

abstract interface class GameRepository {
  Future<Game> insert({
    required int stationId,
    required int winnerTabId,
    required int loserTabId,
    required int price,
  });
  Future<List<Game>> getAll();
  Future<void> delete(int id);
  Future<List<int>> lostPricesFor(int tabId);
  Future<int> wonCountFor(int tabId);

  /// Sum of prices of games lost by tabs that are currently open.
  Future<int> sumLostPricesForOpenTabs();
}
