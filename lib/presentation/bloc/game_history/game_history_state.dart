part of 'game_history_bloc.dart';

class GameHistoryState extends Equatable {
  const GameHistoryState({
    this.loading = false,
    this.entries = const [],
    this.error,
    this.lastUndoResult,
  });

  final bool loading;
  final List<GameHistoryEntry> entries;
  final String? error;
  final UndoGameResult? lastUndoResult;

  @override
  List<Object?> get props => [loading, entries, error, lastUndoResult];
}
