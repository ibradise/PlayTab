import 'package:playtab/domain/entities/app_setting.dart';
import 'package:playtab/domain/entities/game.dart';
import 'package:playtab/domain/entities/payment.dart';
import 'package:playtab/domain/entities/slot.dart';
import 'package:playtab/domain/entities/station.dart';
import 'package:playtab/domain/entities/tab.dart';
import 'package:playtab/domain/entities/tab_status.dart';
import 'package:playtab/domain/repositories/game_repository.dart';
import 'package:playtab/domain/repositories/payment_repository.dart';
import 'package:playtab/domain/repositories/settings_repository.dart';
import 'package:playtab/domain/repositories/station_repository.dart';
import 'package:playtab/domain/repositories/tab_repository.dart';

class FakeTabRepository implements TabRepository {
  final List<Tab> tabs = [];
  int _nextId = 1;

  @override
  Future<Tab> create({String? label}) async {
    final tab = Tab(
      id: _nextId++,
      label: label,
      status: TabStatus.open,
      createdAt: 0,
    );
    tabs.add(tab);
    return tab;
  }

  @override
  Future<List<Tab>> getOpen() async => tabs.where((t) => t.isOpen).toList();

  @override
  Future<Tab?> getById(int id) async {
    for (final tab in tabs) {
      if (tab.id == id) return tab;
    }
    return null;
  }

  @override
  Future<void> updateLabel(int id, String label) async {
    final index = tabs.indexWhere((t) => t.id == id);
    if (index != -1) tabs[index] = tabs[index].copyWith(label: label);
  }

  @override
  Future<void> close(int id) async {
    final index = tabs.indexWhere((t) => t.id == id);
    if (index != -1) {
      tabs[index] = tabs[index].copyWith(status: TabStatus.closed);
    }
  }
}

class FakeStationRepository implements StationRepository {
  FakeStationRepository() {
    stations.add(const Station(id: 1, name: 'TV 1'));
    stations.add(const Station(id: 2, name: 'TV 2'));
    _nextId = 3;
  }

  final List<Station> stations = [];
  int _nextId = 1;

  @override
  Future<List<Station>> getAll() async => [...stations]..sort((a, b) => a.id.compareTo(b.id));

  @override
  Future<Station?> getById(int id) async {
    for (final station in stations) {
      if (station.id == id) return station;
    }
    return null;
  }

  @override
  Future<int> create(String name) async {
    final id = _nextId++;
    stations.add(Station(id: id, name: name));
    return id;
  }

  @override
  Future<void> rename(int id, String name) async {
    final index = stations.indexWhere((s) => s.id == id);
    if (index != -1) stations[index] = stations[index].copyWith(name: name);
  }

  @override
  Future<void> delete(int id) async {
    stations.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> assignTab(int stationId, Slot slot, int tabId) async {
    final index = stations.indexWhere((s) => s.id == stationId);
    if (index == -1) return;
    final station = stations[index];
    stations[index] = station.copyWith(
      slotATabId: slot == Slot.a ? tabId : null,
      slotBTabId: slot == Slot.b ? tabId : null,
    );
  }

  @override
  Future<void> clearSlot(int stationId, Slot slot) async {
    final index = stations.indexWhere((s) => s.id == stationId);
    if (index == -1) return;
    stations[index] = stations[index].copyWith(
      clearA: slot == Slot.a,
      clearB: slot == Slot.b,
    );
  }
}

class FakeGameRepository implements GameRepository {
  FakeGameRepository([this._tabs]);

  final FakeTabRepository? _tabs;
  final List<Game> games = [];
  int _nextId = 1;

  @override
  Future<Game> insert({
    required int stationId,
    required int winnerTabId,
    required int loserTabId,
    required int price,
  }) async {
    final game = Game(
      id: _nextId++,
      stationId: stationId,
      winnerTabId: winnerTabId,
      loserTabId: loserTabId,
      playedAt: 0,
      price: price,
    );
    games.add(game);
    return game;
  }

  @override
  Future<List<Game>> getAll() async => [...games];

  @override
  Future<void> delete(int id) async {
    games.removeWhere((g) => g.id == id);
  }

  @override
  Future<List<int>> lostPricesFor(int tabId) async =>
      [for (final g in games) if (g.loserTabId == tabId) g.price];

  @override
  Future<int> wonCountFor(int tabId) async =>
      games.where((g) => g.winnerTabId == tabId).length;

  @override
  Future<int> sumLostPricesForOpenTabs() async {
    final tabs = _tabs;
    if (tabs == null) return 0;
    return games
        .where((g) =>
            tabs.tabs.any((t) => t.id == g.loserTabId && t.isOpen))
        .fold<int>(0, (sum, g) => sum + g.price);
  }
}

class FakePaymentRepository implements PaymentRepository {
  FakePaymentRepository([this._tabs]);

  final FakeTabRepository? _tabs;
  final List<Payment> payments = [];
  int _nextId = 1;

  /// Adds a payment at a specific time (test-only helper, not in interface).
  void addAt(int tabId, int amount, int paidAt) {
    payments.add(
      Payment(id: _nextId++, tabId: tabId, amount: amount, paidAt: paidAt),
    );
  }

  @override
  Future<void> insert({required int tabId, required int amount}) async {
    payments.add(Payment(id: _nextId++, tabId: tabId, amount: amount, paidAt: 0));
  }

  @override
  Future<List<Payment>> forTab(int tabId) async =>
      [for (final p in payments) if (p.tabId == tabId) p];

  @override
  Future<int> sumFor(int tabId) async {
    var sum = 0;
    for (final p in payments) {
      if (p.tabId == tabId) sum += p.amount;
    }
    return sum;
  }

  @override
  Future<int> sumSince(int fromEpochMs) async =>
      payments.where((p) => p.paidAt >= fromEpochMs).fold<int>(
            0,
            (sum, p) => sum + p.amount,
          );

  @override
  Future<int> sumAll() async =>
      payments.fold<int>(0, (sum, p) => sum + p.amount);

  @override
  Future<int> sumForOpenTabs() async {
    final tabs = _tabs;
    if (tabs == null) return 0;
    return payments
        .where((p) => tabs.tabs.any((t) => t.id == p.tabId && t.isOpen))
        .fold<int>(0, (sum, p) => sum + p.amount);
  }
}

class FakeSettingsRepository implements SettingsRepository {
  AppSetting setting = const AppSetting(pricePerGame: 15);

  @override
  Future<AppSetting> get() async => setting;

  @override
  Future<void> setPricePerGame(int price) async {
    setting = setting.copyWith(pricePerGame: price);
  }
}
