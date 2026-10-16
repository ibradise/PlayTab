import 'package:equatable/equatable.dart';

import 'tab.dart';

class TabWithOwed extends Equatable {
  const TabWithOwed({required this.tab, required this.owed});

  final Tab tab;
  final int owed;

  @override
  List<Object?> get props => [tab, owed];
}
