class AppSetting {
  const AppSetting({required this.pricePerGame});

  static const int settingsRowId = 1;

  final int pricePerGame;

  AppSetting copyWith({int? pricePerGame}) =>
      AppSetting(pricePerGame: pricePerGame ?? this.pricePerGame);

  Map<String, Object?> toMap() => {
        'id': settingsRowId,
        'price_per_game': pricePerGame,
      };

  factory AppSetting.fromMap(Map<String, Object?> map) =>
      AppSetting(pricePerGame: map['price_per_game'] as int);
}
