import 'package:flutter/material.dart' hide Tab;

import '../../core/di.dart';
import '../../domain/entities/tab.dart';
import '../../domain/usecases/get_available_tabs.dart';
import 'new_player_page.dart';

/// Lists open tabs not on any station. Pops with the chosen [Tab].
class PickPlayerPage extends StatefulWidget {
  const PickPlayerPage({super.key});

  @override
  State<PickPlayerPage> createState() => _PickPlayerPageState();
}

class _PickPlayerPageState extends State<PickPlayerPage> {
  late final Future<List<Tab>> _future = sl<GetAvailableTabs>()();

  Future<void> _newPlayer() async {
    final tab = await Navigator.of(context).push<Tab>(
      MaterialPageRoute(builder: (_) => NewPlayerPage(createTab: sl())),
    );
    if (tab != null && mounted) Navigator.of(context).pop(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick player')),
      body: FutureBuilder<List<Tab>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tabs = snapshot.data!;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('New player'),
                onTap: _newPlayer,
              ),
              const Divider(height: 1),
              for (final tab in tabs)
                ListTile(
                  title: Text(tab.displayLabel),
                  onTap: () => Navigator.of(context).pop(tab),
                ),
            ],
          );
        },
      ),
    );
  }
}
