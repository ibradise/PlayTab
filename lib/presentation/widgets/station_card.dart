import 'package:flutter/material.dart';

import '../../domain/entities/slot.dart';
import '../../domain/entities/station_with_tabs.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.data,
    required this.onSlotTap,
    required this.onSlotLongPress,
    required this.onLost,
  });

  final StationWithTabs data;
  final void Function(Slot slot) onSlotTap;
  final void Function(Slot slot) onSlotLongPress;
  final void Function(int loserTabId) onLost;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.station.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _slot(context, Slot.a),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Text(
                  'vs',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            _slot(context, Slot.b),
            if (data.station.isFull) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _lostButton(context, Slot.a)),
                  const SizedBox(width: 12),
                  Expanded(child: _lostButton(context, Slot.b)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lostButton(BuildContext context, Slot slot) {
    final tab = data.tabInSlot(slot)!;
    return OutlinedButton(
      onPressed: () => onLost(tab.id),
      child: Text('${tab.displayLabel} lost'),
    );
  }

  Widget _slot(BuildContext context, Slot slot) {
    final tab = data.tabInSlot(slot);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onSlotTap(slot),
      onLongPress: tab == null ? null : () => onSlotLongPress(slot),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          tab?.displayLabel ?? 'empty slot',
          style: tab == null
              ? theme.textTheme.bodyLarge!.copyWith(color: theme.hintColor)
              : theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
