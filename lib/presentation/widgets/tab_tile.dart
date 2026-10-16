import 'package:flutter/material.dart' hide Tab;

import '../../../core/format.dart';
import '../../../domain/entities/tab.dart';

class TabTile extends StatelessWidget {
  const TabTile({super.key, required this.tab, required this.owed, this.onTap});

  final Tab tab;
  final int owed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(tab.displayLabel),
      trailing: Text(
        formatBirr(owed),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: onTap,
    );
  }
}
