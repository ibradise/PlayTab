import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/station.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../domain/repositories/station_repository.dart';
import '../../../domain/usecases/add_station.dart';
import '../../../domain/usecases/remove_station.dart';
import '../../../domain/usecases/rename_station.dart';
import '../../../domain/usecases/update_price_per_game.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required this.settings,
    required this.stations,
    required this.updatePricePerGame,
    required this.addStation,
    required this.renameStation,
    required this.removeStation,
  }) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<PriceSaveRequested>(_onPrice);
    on<StationAddRequested>(_onAdd);
    on<StationRenameRequested>(_onRename);
    on<StationRemoveRequested>(_onRemove);
    on<SettingsMessageConsumed>(_onConsumed);
  }

  final SettingsRepository settings;
  final StationRepository stations;
  final UpdatePricePerGame updatePricePerGame;
  final AddStation addStation;
  final RenameStation renameStation;
  final RemoveStation removeStation;

  Future<void> _onLoad(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState(loading: true));
    try {
      emit(await _loaded());
    } catch (e) {
      emit(SettingsState(error: e.toString()));
    }
  }

  Future<void> _onPrice(
    PriceSaveRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await updatePricePerGame(event.price);
      emit(await _loaded(message: 'Price updated to ${event.price} birr'));
    } catch (e) {
      emit(_withMessage(e.toString()));
    }
  }

  Future<void> _onAdd(
    StationAddRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await addStation(event.name);
      emit(await _loaded(message: 'Station added'));
    } catch (e) {
      emit(_withMessage(e.toString()));
    }
  }

  Future<void> _onRename(
    StationRenameRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await renameStation(event.stationId, event.name);
      emit(await _loaded(message: 'Station renamed'));
    } catch (e) {
      emit(_withMessage(e.toString()));
    }
  }

  Future<void> _onRemove(
    StationRemoveRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await removeStation(event.stationId);
      emit(await _loaded(message: 'Station removed'));
    } catch (e) {
      emit(_withMessage(e.toString()));
    }
  }

  void _onConsumed(
    SettingsMessageConsumed event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsState(
      pricePerGame: state.pricePerGame,
      stations: state.stations,
    ));
  }

  Future<SettingsState> _loaded({String? message}) async => SettingsState(
        pricePerGame: (await settings.get()).pricePerGame,
        stations: await stations.getAll(),
        message: message,
      );

  SettingsState _withMessage(String message) => SettingsState(
        pricePerGame: state.pricePerGame,
        stations: state.stations,
        message: message,
      );
}
