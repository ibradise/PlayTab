import 'package:flutter/material.dart';

import '../bloc/tabs/tabs_bloc.dart';

class NewPlayerPage extends StatefulWidget {
  const NewPlayerPage({super.key, required this.tabsBloc});

  final TabsBloc tabsBloc;

  @override
  State<NewPlayerPage> createState() => _NewPlayerPageState();
}

class _NewPlayerPageState extends State<NewPlayerPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _create() {
    final label = _controller.text.trim();
    widget.tabsBloc.add(TabCreateRequested(label.isEmpty ? null : label));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _create,
          child: const Text('Create'),
        ),
      ),
    );
  }
}
