part of 'game_history_bloc.dart';

sealed class GameHistoryEvent extends Equatable {
  const GameHistoryEvent();

  @override
  List<Object?> get props => [];
}

class GameHistoryLoadRequested extends GameHistoryEvent {
  const GameHistoryLoadRequested();
}

class UndoGameRequested extends GameHistoryEvent {
  const UndoGameRequested(this.gameId);

  final int gameId;

  @override
  List<Object?> get props => [gameId];
}

class UndoResultConsumed extends GameHistoryEvent {
  const UndoResultConsumed();
}
