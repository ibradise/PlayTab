class AppSetting {
  const AppSetting({
    required this.pricePerGame,
    this.darkMode = false,
  });

  static const int settingsRowId = 1;

  final int pricePerGame;

  /// Theme choice (persisted): false = light glass, true = midnight indigo.
  final bool darkMode;

  AppSetting copyWith({int? pricePerGame, bool? darkMode}) => AppSetting(
        pricePerGame: pricePerGame ?? this.pricePerGame,
        darkMode: darkMode ?? this.darkMode,
      );

  Map<String, Object?> toMap() => {
        'id': settingsRowId,
        'price_per_game': pricePerGame,
        'dark_mode': darkMode ? 1 : 0,
      };

  factory AppSetting.fromMap(Map<String, Object?> map) => AppSetting(
        pricePerGame: map['price_per_game'] as int,
        darkMode: ((map['dark_mode'] ?? 0) as int) != 0,
      );
}
