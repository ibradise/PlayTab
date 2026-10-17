import 'package:flutter/material.dart' hide Tab;

import '../../core/di.dart';
import '../../domain/entities/tab.dart';
import '../../domain/entities/tab_candidate.dart';
import '../../domain/usecases/get_pick_candidates.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import 'new_player_page.dart';

/// Lists open tabs: waiting ones first, then ones on other stations
/// (choosing one confirms a move). Pops with the chosen [Tab].
class PickPlayerPage extends StatefulWidget {
  const PickPlayerPage({super.key});

  @override
  State<PickPlayerPage> createState() => _PickPlayerPageState();
}

class _PickPlayerPageState extends State<PickPlayerPage> {
  late final Future<List<TabCandidate>> _future = sl<GetPickCandidates>()();

  Future<void> _select(TabCandidate candidate) async {
    if (candidate.onStation) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Move ${candidate.tab.displayLabel}?'),
          content: Text(
            'They are currently on ${candidate.currentStation!.name}. '
            'They will be removed from that station.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Move'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (mounted) Navigator.of(context).pop(candidate.tab);
  }

  Future<void> _newPlayer() async {
    final tab = await Navigator.of(context).push<Tab>(
      MaterialPageRoute(builder: (_) => NewPlayerPage(createTab: sl())),
    );
    if (tab != null && mounted) Navigator.of(context).pop(tab);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pick player',
      body: FutureBuilder<List<TabCandidate>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final candidates = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('New player'),
                      onTap: _newPlayer,
                    ),
                    for (final candidate in candidates)
                      ListTile(
                        title: Text(candidate.tab.displayLabel),
                        subtitle: candidate.onStation
                            ? Text('on ${candidate.currentStation!.name}')
                            : null,
                        onTap: () => _select(candidate),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
