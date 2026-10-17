part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

class PriceSaveRequested extends SettingsEvent {
  const PriceSaveRequested(this.price);

  final int price;

  @override
  List<Object?> get props => [price];
}

class StationAddRequested extends SettingsEvent {
  const StationAddRequested(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

class StationRenameRequested extends SettingsEvent {
  const StationRenameRequested({required this.stationId, required this.name});

  final int stationId;
  final String name;

  @override
  List<Object?> get props => [stationId, name];
}

class StationRemoveRequested extends SettingsEvent {
  const StationRemoveRequested(this.stationId);

  final int stationId;

  @override
  List<Object?> get props => [stationId];
}

/// Persist + apply the app-wide theme choice.
class ThemeToggleRequested extends SettingsEvent {
  const ThemeToggleRequested(this.dark);

  final bool dark;

  @override
  List<Object?> get props => [dark];
}

class SettingsMessageConsumed extends SettingsEvent {
  const SettingsMessageConsumed();
}
