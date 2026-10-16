import 'package:equatable/equatable.dart';

import 'slot.dart';

class Station extends Equatable {
  const Station({
    required this.id,
    required this.name,
    this.slotATabId,
    this.slotBTabId,
  });

  final int id;
  final String name;
  final int? slotATabId;
  final int? slotBTabId;

  bool get isFull => slotATabId != null && slotBTabId != null;

  int? tabIdInSlot(Slot slot) => slot == Slot.a ? slotATabId : slotBTabId;

  bool hasTab(int tabId) => slotATabId == tabId || slotBTabId == tabId;

  @override
  List<Object?> get props => [id, name, slotATabId, slotBTabId];

  Station copyWith({
    int? id,
    String? name,
    int? slotATabId,
    int? slotBTabId,
    bool clearA = false,
    bool clearB = false,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      slotATabId: clearA ? null : (slotATabId ?? this.slotATabId),
      slotBTabId: clearB ? null : (slotBTabId ?? this.slotBTabId),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'slot_a_tab_id': slotATabId,
        'slot_b_tab_id': slotBTabId,
      };

  factory Station.fromMap(Map<String, Object?> map) => Station(
        id: map['id'] as int,
        name: map['name'] as String,
        slotATabId: map['slot_a_tab_id'] as int?,
        slotBTabId: map['slot_b_tab_id'] as int?,
      );
}
