part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.loading = false,
    this.error,
    this.pricePerGame,
    this.stations = const [],
    this.message,
  });

  final bool loading;
  final String? error;
  final int? pricePerGame;
  final List<Station> stations;
  final String? message;

  @override
  List<Object?> get props =>
      [loading, error, pricePerGame, stations, message];
}
