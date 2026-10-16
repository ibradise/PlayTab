import 'package:equatable/equatable.dart';

import 'slot.dart';
import 'station.dart';
import 'tab.dart';

class StationWithTabs extends Equatable {
  const StationWithTabs({required this.station, this.slotA, this.slotB});

  final Station station;
  final Tab? slotA;
  final Tab? slotB;

  Tab? tabInSlot(Slot slot) => slot == Slot.a ? slotA : slotB;

  @override
  List<Object?> get props => [station, slotA, slotB];
}
