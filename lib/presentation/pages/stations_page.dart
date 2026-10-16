import 'package:flutter/material.dart' hide Tab;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di.dart';
import '../../domain/entities/slot.dart';
import '../../domain/entities/tab.dart';
import '../bloc/stations/stations_bloc.dart';
import '../widgets/station_card.dart';
import 'new_player_page.dart';
import 'open_tabs_page.dart';
import 'pick_player_page.dart';

class StationsPage extends StatelessWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StationsBloc(
        getStationsWithTabs: sl(),
        assignTabToSlot: sl(),
        clearSlot: sl(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PS Zone')),
      body: BlocBuilder<StationsBloc, StationsState>(
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
                ),
            ],
          );
        },
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
