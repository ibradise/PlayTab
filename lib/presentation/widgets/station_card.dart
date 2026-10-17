import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../domain/entities/slot.dart';
import '../../domain/entities/station_with_tabs.dart';
import 'glass_card.dart';
import 'ps_shapes.dart';

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
    final theme = Theme.of(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.station.isFull ? kPsShapeGreen : kPsShapeBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.station.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (data.station.isFull)
                const Text(
                  'FULL',
                  style: TextStyle(
                    color: kPsShapeGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _slot(context, Slot.a),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Center(
              child: PsShapeStrip(size: 9, spacing: 8),
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
    final brightness = theme.brightness;
    final tileFill =
        tab == null ? Colors.transparent : GlassColors.tileFill(brightness);
    final borderColor = tab == null
        ? GlassColors.border(brightness).withValues(
            alpha: brightness == Brightness.dark ? 0.5 : 0.65,
          )
        : GlassColors.border(brightness);

    return InkWell(
      onTap: () => onSlotTap(slot),
      onLongPress: tab == null ? null : () => onSlotLongPress(slot),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: tileFill,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tab?.displayLabel ?? 'empty slot',
                style: tab == null
                    ? theme.textTheme.bodyLarge!
                        .copyWith(color: theme.colorScheme.onSurfaceVariant)
                    : theme.textTheme.titleMedium,
              ),
            ),
            if (tab == null)
              Opacity(
                opacity: brightness == Brightness.dark ? 0.55 : 0.45,
                child: const PsShapeStrip(size: 8, spacing: 3),
              ),
          ],
        ),
      ),
    );
  }
}
