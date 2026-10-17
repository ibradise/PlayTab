import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../../domain/usecases/create_tab.dart';

/// Creates a tab and pops with the created [Tab] (or null on cancel).
class NewPlayerPage extends StatefulWidget {
  const NewPlayerPage({super.key, required this.createTab});

  final CreateTab createTab;

  @override
  State<NewPlayerPage> createState() => _NewPlayerPageState();
}

class _NewPlayerPageState extends State<NewPlayerPage> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);
    final label = _controller.text.trim();
    final tab = await widget.createTab(label: label.isEmpty ? null : label);
    if (mounted) Navigator.of(context).pop(tab);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'New player',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          opacity: 0.9,
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _create(),
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
              hintText: 'e.g. Abebe, red shirt',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _saving ? null : _create,
          child: const Text('Create'),
        ),
      ),
    );
  }
}
