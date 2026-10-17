import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di.dart';
import '../../domain/entities/station.dart';
import '../bloc/settings/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _priceController = TextEditingController();
  bool _priceSeeded = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsBloc(
        settings: sl(),
        stations: sl(),
        updatePricePerGame: sl(),
        addStation: sl(),
        renameStation: sl(),
        removeStation: sl(),
      )..add(const SettingsLoadRequested()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            current.message != null && current.message != previous.message,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message!),
                duration: const Duration(seconds: 4),
              ),
            );
          context.read<SettingsBloc>().add(const SettingsMessageConsumed());
        },
        builder: (context, state) {
          if (state.pricePerGame != null && !_priceSeeded) {
            _priceController.text = state.pricePerGame.toString();
            _priceSeeded = true;
          }
          final bloc = context.read<SettingsBloc>();

          return Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: state.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            state.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      Text(
                        'Price per game',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Birr',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () => _savePrice(bloc),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Stations',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _addStation(bloc),
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final station in state.stations)
                        ListTile(
                          title: Text(station.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Rename',
                                onPressed: () => _renameStation(
                                  bloc,
                                  station,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Remove',
                                onPressed: () => _removeStation(
                                  context,
                                  bloc,
                                  station,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _savePrice(SettingsBloc bloc) {
    final price = int.tryParse(_priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Enter a whole number of birr'),
            duration: Duration(seconds: 4),
          ),
        );
      return;
    }
    bloc.add(PriceSaveRequested(price));
  }

  Future<void> _addStation(SettingsBloc bloc) async {
    final name = await _promptName(context, title: 'Add station');
    if (name == null) return;
    bloc.add(StationAddRequested(name));
  }

  Future<void> _renameStation(SettingsBloc bloc, Station station) async {
    final name = await _promptName(
      context,
      title: 'Rename station',
      initial: station.name,
    );
    if (name == null) return;
    bloc.add(StationRenameRequested(stationId: station.id, name: name));
  }

  Future<void> _removeStation(
    BuildContext context,
    SettingsBloc bloc,
    Station station,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${station.name}?'),
        content: const Text('Players waiting there will go back to waiting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    bloc.add(StationRemoveRequested(station.id));
  }
}

Future<String?> _promptName(
  BuildContext context, {
  required String title,
  String? initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _NameDialog(title: title, initial: initial),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, this.initial});

  final String title;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
