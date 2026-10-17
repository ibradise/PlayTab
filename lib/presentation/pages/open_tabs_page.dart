import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di.dart';
import '../../../core/format.dart';
import '../bloc/tabs/tabs_bloc.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/tab_tile.dart';
import 'new_player_page.dart';
import 'tab_detail_page.dart';

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

  Future<void> _openDetail(BuildContext context, int tabId) async {
    final bloc = context.read<TabsBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TabDetailPage(tabId: tabId)),
    );
    bloc.add(const TabsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabsBloc, TabsState>(
      builder: (context, state) {
        return AppScaffold(
          title: 'Open tabs',
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text(state.error!))
                  : state.tabs.isEmpty
                      ? const Center(child: Text('No open tabs'))
                      : ListView.separated(
                          itemCount: state.tabs.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final t = state.tabs[i];
                            return TabTile(
                              tab: t.tab,
                              owed: t.owed,
                              onTap: () => _openDetail(context, t.tab.id),
                            );
                          },
                        ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openNewPlayer(context),
            icon: const Icon(Icons.person_add),
            label: const Text('New player'),
          ),
        );
      },
    );
  }
}
