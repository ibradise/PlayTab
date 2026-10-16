import 'package:equatable/equatable.dart';

import 'game.dart';
import 'slot.dart';
import 'tab.dart';

class RecordGameOutcome extends Equatable {
  const RecordGameOutcome({
    required this.game,
    required this.freedSlot,
    this.autoPlacedTab,
  });

  final Game game;
  final Slot freedSlot;

  /// Waiting tab that was auto-placed into the freed slot, if exactly one
  /// was waiting.
  final Tab? autoPlacedTab;

  bool get needsPick => autoPlacedTab == null;

  @override
  List<Object?> get props => [game, freedSlot, autoPlacedTab];
}
