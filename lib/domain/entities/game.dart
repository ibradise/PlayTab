import 'package:equatable/equatable.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.stationId,
    required this.winnerTabId,
    required this.loserTabId,
    required this.playedAt,
    required this.price,
  });

  final int id;
  final int stationId;
  final int winnerTabId;
  final int loserTabId;
  final int playedAt;
  final int price;

  @override
  List<Object?> get props =>
      [id, stationId, winnerTabId, loserTabId, playedAt, price];

  Map<String, Object?> toMap() => {
        'id': id,
        'station_id': stationId,
        'winner_tab_id': winnerTabId,
        'loser_tab_id': loserTabId,
        'played_at': playedAt,
        'price': price,
      };

  factory Game.fromMap(Map<String, Object?> map) => Game(
        id: map['id'] as int,
        stationId: map['station_id'] as int,
        winnerTabId: map['winner_tab_id'] as int,
        loserTabId: map['loser_tab_id'] as int,
        playedAt: map['played_at'] as int,
        price: map['price'] as int,
      );
}
