import 'package:equatable/equatable.dart';

import 'station.dart';
import 'tab.dart';

class TabCandidate extends Equatable {
  const TabCandidate({required this.tab, this.currentStation});

  final Tab tab;

  /// Non-null when the tab is currently placed on a station; null when the
  /// tab is waiting (not on any station).
  final Station? currentStation;

  bool get onStation => currentStation != null;

  @override
  List<Object?> get props => [tab, currentStation];
}
