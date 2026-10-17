import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/record_game_outcome.dart';
import '../../../domain/entities/slot.dart';
import '../../../domain/entities/station_with_tabs.dart';
import '../../../domain/usecases/assign_tab_to_slot.dart';
import '../../../domain/usecases/clear_slot.dart';
import '../../../domain/usecases/get_stations_with_tabs.dart';
import '../../../domain/usecases/record_game_result.dart';
import '../../../domain/usecases/undo_last_game.dart';

part 'stations_event.dart';
part 'stations_state.dart';

class StationsBloc extends Bloc<StationsEvent, StationsState> {
  StationsBloc({
    required this.getStationsWithTabs,
    required this.assignTabToSlot,
    required this.clearSlot,
    required this.recordGameResult,
    required this.undoLastGame,
  }) : super(const StationsState()) {
    on<StationsLoadRequested>(_onLoad);
    on<TabAssigned>(_onAssign);
    on<SlotClearedEvent>(_onClear);
    on<LossRecorded>(_onLoss);
    on<UndoRequested>(_onUndo);
    on<OutcomeConsumed>(_onOutcomeConsumed);
    on<StationsErrorConsumed>(_onErrorConsumed);
  }

  final GetStationsWithTabs getStationsWithTabs;
  final AssignTabToSlot assignTabToSlot;
  final ClearSlot clearSlot;
  final RecordGameResult recordGameResult;
  final UndoLastGame undoLastGame;

  Future<void> _onLoad(
    StationsLoadRequested event,
    Emitter<StationsState> emit,
  ) async {
    emit(const StationsState(loading: true));
    try {
      emit(StationsState(stations: await getStationsWithTabs()));
    } catch (e) {
      emit(StationsState(error: e.toString()));
    }
  }

  Future<void> _onAssign(
    TabAssigned event,
    Emitter<StationsState> emit,
  ) async {
    try {
      await assignTabToSlot(
        stationId: event.stationId,
        slot: event.slot,
        tabId: event.tabId,
      );
      await _reload(emit);
    } catch (e) {
      emit(StationsState(stations: await _safeStations(), error: e.toString()));
    }
  }

  Future<void> _onClear(
    SlotClearedEvent event,
    Emitter<StationsState> emit,
  ) async {
    try {
      await clearSlot(stationId: event.stationId, slot: event.slot);
      await _reload(emit);
    } catch (e) {
      emit(StationsState(stations: await _safeStations(), error: e.toString()));
    }
  }

  Future<void> _onLoss(
    LossRecorded event,
    Emitter<StationsState> emit,
  ) async {
    try {
      final outcome = await recordGameResult(
        stationId: event.stationId,
        loserTabId: event.loserTabId,
      );
      final stations = await getStationsWithTabs();
      emit(StationsState(stations: stations, lastOutcome: outcome));
    } catch (e) {
      emit(StationsState(stations: await _safeStations(), error: e.toString()));
    }
  }

  Future<void> _onUndo(
    UndoRequested event,
    Emitter<StationsState> emit,
  ) async {
    try {
      await undoLastGame();
      await _reload(emit);
    } catch (e) {
      emit(StationsState(stations: await _safeStations(), error: e.toString()));
    }
  }

  void _onOutcomeConsumed(
    OutcomeConsumed event,
    Emitter<StationsState> emit,
  ) {
    emit(StationsState(stations: state.stations));
  }

  void _onErrorConsumed(
    StationsErrorConsumed event,
    Emitter<StationsState> emit,
  ) {
    emit(StationsState(stations: state.stations));
  }

  Future<void> _reload(Emitter<StationsState> emit) async {
    emit(StationsState(stations: await getStationsWithTabs()));
  }

  Future<List<StationWithTabs>> _safeStations() async {
    try {
      return await getStationsWithTabs();
    } catch (_) {
      return state.stations;
    }
  }
}
