import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/slot.dart';
import '../../../domain/entities/station_with_tabs.dart';
import '../../../domain/usecases/assign_tab_to_slot.dart';
import '../../../domain/usecases/clear_slot.dart';
import '../../../domain/usecases/get_stations_with_tabs.dart';

part 'stations_event.dart';
part 'stations_state.dart';

class StationsBloc extends Bloc<StationsEvent, StationsState> {
  StationsBloc({
    required this.getStationsWithTabs,
    required this.assignTabToSlot,
    required this.clearSlot,
  }) : super(const StationsState()) {
    on<StationsLoadRequested>(_onLoad);
    on<TabAssigned>(_onAssign);
    on<SlotClearedEvent>(_onClear);
  }

  final GetStationsWithTabs getStationsWithTabs;
  final AssignTabToSlot assignTabToSlot;
  final ClearSlot clearSlot;

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
      add(const StationsLoadRequested());
    } catch (e) {
      emit(StationsState(error: e.toString(), stations: state.stations));
    }
  }

  Future<void> _onClear(
    SlotClearedEvent event,
    Emitter<StationsState> emit,
  ) async {
    try {
      await clearSlot(stationId: event.stationId, slot: event.slot);
      add(const StationsLoadRequested());
    } catch (e) {
      emit(StationsState(error: e.toString(), stations: state.stations));
    }
  }
}
