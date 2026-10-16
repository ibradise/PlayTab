import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di.dart';
import '../../core/format.dart';
import '../../domain/entities/payment_action.dart';
import '../../domain/entities/tab_detail.dart';
import '../bloc/tab_detail/tab_detail_bloc.dart';

class TabDetailPage extends StatelessWidget {
  const TabDetailPage({super.key, required this.tabId});

  final int tabId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TabDetailBloc(
        tabId: tabId,
        getTabDetail: sl(),
        markPaid: sl(),
        closeTab: sl(),
        tabs: sl(),
      )..add(const TabDetailLoadRequested()),
      child: const _TabDetailView(),
    );
  }
}

class _TabDetailView extends StatelessWidget {
  const _TabDetailView();

  Future<void> _markPaid(BuildContext context, TabDetail detail) async {
    final bloc = context.read<TabDetailBloc>();
    final close = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark paid'),
        content: Text(
          '${detail.stats.lost} losses × ${formatBirr(detail.pricePerGame)}'
          ' = ${formatBirr(detail.owed)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep open'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Close tab'),
          ),
        ],
      ),
    );
    if (close != null) {
      bloc.add(MarkPaidRequested(close: close));
    }
  }

  Future<void> _editLabel(BuildContext context, TabDetail detail) async {
    final bloc = context.read<TabDetailBloc>();
    final controller = TextEditingController(text: detail.tab.label ?? '');
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Label',
            hintText: 'e.g. Abebe, red shirt',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (label != null) {
      bloc.add(LabelEditRequested(label));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tab detail')),
      body: BlocConsumer<TabDetailBloc, TabDetailState>(
        listenWhen: (previous, current) =>
            current.lastPaymentAction != null &&
            current.lastPaymentAction != previous.lastPaymentAction,
        listener: (context, state) {
          if (state.lastPaymentAction == PaymentAction.closeTab) {
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment recorded')),
            );
            context.read<TabDetailBloc>().add(const PaymentActionConsumed());
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = state.detail;
          if (detail == null) {
            return const Center(child: Text('Tab not found'));
          }
          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(detail.tab.displayLabel,
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('Amount owed: ${formatBirr(detail.owed)}',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              if (detail.owed > 0)
                FilledButton(
                  onPressed: () => _markPaid(context, detail),
                  child: const Text('Mark paid'),
                )
              else
                FilledButton(
                  onPressed: () =>
                      context.read<TabDetailBloc>().add(const CloseTabRequested()),
                  child: const Text('Close tab'),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => _editLabel(context, detail),
                child: const Text('Edit label'),
              ),
              const SizedBox(height: 24),
              Text('Stats', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _statRow('Played', detail.stats.played),
              _statRow('Won', detail.stats.won),
              _statRow('Lost', detail.stats.lost),
              if (detail.headToHead.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Head-to-head', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final h in detail.headToHead)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(h.other.displayLabel),
                    trailing: Text('${h.wonAgainst} - ${h.lostAgainst}'),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _statRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text('$value')],
      ),
    );
  }
}
