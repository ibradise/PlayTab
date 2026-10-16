part of 'stations_bloc.dart';

sealed class StationsEvent extends Equatable {
  const StationsEvent();

  @override
  List<Object?> get props => [];
}

class StationsLoadRequested extends StationsEvent {
  const StationsLoadRequested();
}

class TabAssigned extends StationsEvent {
  const TabAssigned({
    required this.stationId,
    required this.slot,
    required this.tabId,
  });

  final int stationId;
  final Slot slot;
  final int tabId;

  @override
  List<Object?> get props => [stationId, slot, tabId];
}

class SlotClearedEvent extends StationsEvent {
  const SlotClearedEvent({required this.stationId, required this.slot});

  final int stationId;
  final Slot slot;

  @override
  List<Object?> get props => [stationId, slot];
}
