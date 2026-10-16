import 'package:equatable/equatable.dart';

import 'tab.dart';

class TabDetail extends Equatable {
  const TabDetail({
    required this.tab,
    required this.owed,
    required this.losses,
    required this.pricePerGame,
  });

  final Tab tab;
  final int owed;
  final int losses;
  final int pricePerGame;

  @override
  List<Object?> get props => [tab, owed, losses, pricePerGame];
}
