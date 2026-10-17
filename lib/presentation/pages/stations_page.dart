import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di.dart';
import '../../core/format.dart';
import '../../domain/entities/record_game_outcome.dart';
import '../../domain/entities/slot.dart';
import '../../domain/entities/tab.dart';
import '../../domain/repositories/tab_repository.dart';
import '../bloc/stations/stations_bloc.dart';
import '../widgets/station_card.dart';
import 'game_history_page.dart';
import 'new_player_page.dart';
import 'open_tabs_page.dart';
import 'pick_player_page.dart';
import 'settings_page.dart';

class StationsPage extends StatelessWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StationsBloc(
        getStationsWithTabs: sl(),
        assignTabToSlot: sl(),
        clearSlot: sl(),
        recordGameResult: sl(),
        undoLastGame: sl(),
      )..add(const StationsLoadRequested()),
      child: const _StationsView(),
    );
  }
}

class _StationsView extends StatelessWidget {
  const _StationsView();

  Future<void> _pickAndAssign(
    BuildContext context,
    int stationId,
    Slot slot,
  ) async {
    final bloc = context.read<StationsBloc>();
    final tab = await Navigator.of(context).push<Tab>(
      MaterialPageRoute(builder: (_) => const PickPlayerPage()),
    );
    if (tab != null) {
      bloc.add(TabAssigned(stationId: stationId, slot: slot, tabId: tab.id));
    }
  }

  Future<void> _confirmClear(
    BuildContext context,
    int stationId,
    Slot slot,
  ) async {
    final bloc = context.read<StationsBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from station?'),
        content: const Text('The tab stays open and keeps its owed amount.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      bloc.add(SlotClearedEvent(stationId: stationId, slot: slot));
    }
  }

  Future<void> _handleOutcome(
    BuildContext context,
    RecordGameOutcome outcome,
  ) async {
    final bloc = context.read<StationsBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final loser =
        await sl<TabRepository>().getById(outcome.game.loserTabId);
    final loserName = loser?.displayLabel ?? '#${outcome.game.loserTabId}';

    // Replace any queued bar so tapping several games quickly never leaves
    // an old bar (whose Undo would target the wrong game) on screen.
    messenger
      ..clearSnackBars()
      ..showSnackBar(
      SnackBar(
        content: Text(
          '$loserName lost • +${formatBirr(outcome.game.price)}',
        ),
        duration: const Duration(seconds: 4),
        persist: false,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => bloc.add(const UndoRequested()),
        ),
      ),
    );
    bloc.add(const OutcomeConsumed());

    if (outcome.needsPick) {
      final picked = await navigator.push<Tab>(
        MaterialPageRoute(builder: (_) => const PickPlayerPage()),
      );
      if (picked != null) {
        bloc.add(TabAssigned(
          stationId: outcome.game.stationId,
          slot: outcome.freedSlot,
          tabId: picked.id,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PS Zone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () async {
              final bloc = context.read<StationsBloc>();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              bloc.add(const StationsLoadRequested());
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Game history',
            onPressed: () async {
              final bloc = context.read<StationsBloc>();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GameHistoryPage()),
              );
              bloc.add(const StationsLoadRequested());
            },
          ),
        ],
      ),
      body: BlocListener<StationsBloc, StationsState>(
        listenWhen: (previous, current) =>
            current.lastOutcome != null &&
            current.lastOutcome != previous.lastOutcome,
        listener: (context, state) =>
            _handleOutcome(context, state.lastOutcome!),
        child: BlocBuilder<StationsBloc, StationsState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final data in state.stations)
                  StationCard(
                    data: data,
                    onSlotTap: (slot) =>
                        _pickAndAssign(context, data.station.id, slot),
                    onSlotLongPress: (slot) =>
                        _confirmClear(context, data.station.id, slot),
                    onLost: (loserTabId) => context.read<StationsBloc>().add(
                          LossRecorded(
                            stationId: data.station.id,
                            loserTabId: loserTabId,
                          ),
                        ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OpenTabsPage()),
                ),
                icon: const Icon(Icons.list),
                label: const Text('Open tabs'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewPlayerPage(createTab: sl()),
                  ),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('New player'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
