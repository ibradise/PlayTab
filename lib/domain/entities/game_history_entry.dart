import 'package:equatable/equatable.dart';

import 'game.dart';

class GameHistoryEntry extends Equatable {
  const GameHistoryEntry({
    required this.game,
    required this.stationName,
    required this.winnerLabel,
    required this.loserLabel,
  });

  final Game game;
  final String stationName;
  final String winnerLabel;
  final String loserLabel;

  @override
  List<Object?> get props => [game, stationName, winnerLabel, loserLabel];
}
