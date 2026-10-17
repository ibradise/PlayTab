import 'package:flutter/material.dart';

import '../../core/di.dart';
import '../../core/format.dart';
import '../../domain/entities/money_report.dart';
import '../../domain/usecases/get_money_report.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  late Future<MoneyReport> _future = _load();

  Future<MoneyReport> _load() => sl<GetMoneyReport>()();

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money')),
      body: FutureBuilder<MoneyReport>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Could not load: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }
          return _MoneyView(snapshot.data!);
        },
      ),
    );
  }
}

class _MoneyView extends StatelessWidget {
  const _MoneyView(this.report);

  final MoneyReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _BigStat(
          label: 'Collected today',
          value: formatBirr(report.collectedToday),
        ),
        const SizedBox(height: 8),
        _StatCard(
          children: [
            _StatRow(
              label: 'Last 7 days (incl. today)',
              value: formatBirr(report.collectedLast7Days),
              subtitle:
                  'avg ${formatBirrDecimal(report.averagePerDay7)} / day',
            ),
            const Divider(height: 16),
            _StatRow(
              label: 'Last 30 days (incl. today)',
              value: formatBirr(report.collectedLast30Days),
              subtitle:
                  'avg ${formatBirrDecimal(report.averagePerDay30)} / day',
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StatCard(
          children: [
            _StatRow(
              label: 'Total collected so far',
              value: formatBirr(report.totalCollected),
            ),
            const Divider(height: 16),
            _StatRow(
              label: 'Owed now (open tabs)',
              value: formatBirr(report.owedNow),
              highlight: report.owedNow > 0,
            ),
          ],
        ),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String? subtitle;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
