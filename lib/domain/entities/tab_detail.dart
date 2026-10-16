import 'package:equatable/equatable.dart';

import 'head_to_head_entry.dart';
import 'tab.dart';
import 'tab_stats.dart';

class TabDetail extends Equatable {
  const TabDetail({
    required this.tab,
    required this.owed,
    required this.stats,
    required this.pricePerGame,
    required this.headToHead,
  });

  final Tab tab;
  final int owed;
  final TabStats stats;
  final int pricePerGame;
  final List<HeadToHeadEntry> headToHead;

  @override
  List<Object?> get props => [tab, owed, stats, pricePerGame, headToHead];
}
