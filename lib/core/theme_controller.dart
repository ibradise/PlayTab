import 'package:flutter/material.dart';

import '../domain/repositories/settings_repository.dart';

/// Holds the app-wide theme choice. Lives in `sl`; the settings page writes
/// through it after persisting, and `MaterialApp` rebuilds on notify — a
/// single synchronous color swap, no restart, no flash.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Loads the persisted choice at startup (before first frame).
  Future<void> init(SettingsRepository settings) async {
    try {
      final setting = await settings.get();
      _mode = setting.darkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      // Storage unavailable: keep the default (light) — never crash on theme.
    }
    notifyListeners();
  }

  /// Applies (does not persist — settings writes first).
  void setDark(bool dark) {
    if (_mode == (dark ? ThemeMode.dark : ThemeMode.light)) return;
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
