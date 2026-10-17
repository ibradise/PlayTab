import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di.dart';
import '../../core/format.dart';
import '../bloc/game_history/game_history_bloc.dart';
import '../widgets/app_scaffold.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameHistoryBloc(
        getGameHistory: sl(),
        undoGame: sl(),
      )..add(const GameHistoryLoadRequested()),
      child: const _GameHistoryView(),
    );
  }
}

class _GameHistoryView extends StatelessWidget {
  const _GameHistoryView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Game history',
      body: BlocConsumer<GameHistoryBloc, GameHistoryState>(
        listenWhen: (previous, current) =>
            current.lastUndoResult != null &&
            current.lastUndoResult != previous.lastUndoResult,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.lastUndoResult!.displayMessage),
                duration: const Duration(seconds: 4),
              ),
            );
          context
              .read<GameHistoryBloc>()
              .add(const UndoResultConsumed());
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          if (state.entries.isEmpty) {
            return const Center(child: Text('No games yet'));
          }
          return ListView.separated(
            itemCount: state.entries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = state.entries[index];
              return ListTile(
                title: Text('${e.winnerLabel} beat ${e.loserLabel}'),
                subtitle: Text(
                  '${e.stationName} • ${formatDateTime(e.game.playedAt)}'
                  ' • ${formatBirr(e.game.price)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: () => context
                      .read<GameHistoryBloc>()
                      .add(UndoGameRequested(e.game.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
