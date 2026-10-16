import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/game_history_entry.dart';
import '../../../domain/entities/undo_game_result.dart';
import '../../../domain/usecases/get_game_history.dart';
import '../../../domain/usecases/undo_game.dart';

part 'game_history_event.dart';
part 'game_history_state.dart';

class GameHistoryBloc extends Bloc<GameHistoryEvent, GameHistoryState> {
  GameHistoryBloc({
    required this.getGameHistory,
    required this.undoGame,
  }) : super(const GameHistoryState()) {
    on<GameHistoryLoadRequested>(_onLoad);
    on<UndoGameRequested>(_onUndo);
    on<UndoResultConsumed>(_onConsumed);
  }

  final GetGameHistory getGameHistory;
  final UndoGame undoGame;

  Future<void> _onLoad(
    GameHistoryLoadRequested event,
    Emitter<GameHistoryState> emit,
  ) async {
    emit(const GameHistoryState(loading: true));
    try {
      emit(GameHistoryState(entries: await getGameHistory()));
    } catch (e) {
      emit(GameHistoryState(error: e.toString()));
    }
  }

  Future<void> _onUndo(
    UndoGameRequested event,
    Emitter<GameHistoryState> emit,
  ) async {
    try {
      final result = await undoGame(event.gameId);
      final entries = await getGameHistory();
      emit(GameHistoryState(entries: entries, lastUndoResult: result));
    } catch (e) {
      emit(GameHistoryState(
        error: e.toString(),
        entries: state.entries,
        lastUndoResult: state.lastUndoResult,
      ));
    }
  }

  void _onConsumed(
    UndoResultConsumed event,
    Emitter<GameHistoryState> emit,
  ) {
    emit(GameHistoryState(entries: state.entries));
  }
}
