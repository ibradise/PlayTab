import 'package:equatable/equatable.dart';

class TabStats extends Equatable {
  const TabStats({required this.played, required this.won, required this.lost});

  final int played;
  final int won;
  final int lost;

  @override
  List<Object?> get props => [played, won, lost];
}
