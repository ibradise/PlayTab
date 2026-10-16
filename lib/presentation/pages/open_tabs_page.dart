import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di.dart';
import '../../../core/format.dart';
import '../bloc/tabs/tabs_bloc.dart';
import '../widgets/tab_tile.dart';
import 'new_player_page.dart';

class OpenTabsPage extends StatelessWidget {
  const OpenTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          TabsBloc(tabs: sl(), getOpenTabs: sl())..add(const TabsLoadRequested()),
      child: const _OpenTabsView(),
    );
  }
}

class _OpenTabsView extends StatelessWidget {
  const _OpenTabsView();

  Future<void> _openNewPlayer(BuildContext context) async {
    final bloc = context.read<TabsBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewPlayerPage(createTab: sl())),
    );
    bloc.add(const TabsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open tabs')),
      body: BlocBuilder<TabsBloc, TabsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          if (state.tabs.isEmpty) {
            return const Center(child: Text('No open tabs'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: state.tabs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = state.tabs[i];
                    return TabTile(tab: t.tab, owed: t.owed);
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total owed:'),
                    Text(
                      formatBirr(state.totalOwed),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewPlayer(context),
        icon: const Icon(Icons.person_add),
        label: const Text('New player'),
      ),
    );
  }
}
