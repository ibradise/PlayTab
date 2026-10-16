import 'package:equatable/equatable.dart';

import 'tab.dart';

class HeadToHeadEntry extends Equatable {
  const HeadToHeadEntry({
    required this.other,
    required this.wonAgainst,
    required this.lostAgainst,
  });

  final Tab other;
  final int wonAgainst;
  final int lostAgainst;

  @override
  List<Object?> get props => [other, wonAgainst, lostAgainst];
}
