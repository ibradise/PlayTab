import 'package:equatable/equatable.dart';

import 'tab_status.dart';

class Tab extends Equatable {
  const Tab({
    required this.id,
    this.label,
    required this.status,
    required this.createdAt,
    this.closedAt,
    this.displayNumber,
  });

  final int id;
  final String? label;
  final TabStatus status;
  final int createdAt;
  final int? closedAt;

  final int? displayNumber;

  /// Recycled number (smallest free among open tabs); falls back to id for
  /// tabs from before the column existed.
  int get number => displayNumber ?? id;

  String get displayLabel =>
      (label == null || label!.isEmpty) ? '#$number' : '#$number $label';

  bool get isOpen => status == TabStatus.open;

  @override
  List<Object?> get props =>
      [id, label, status, createdAt, closedAt, displayNumber];

  Tab copyWith({
    int? id,
    String? label,
    TabStatus? status,
    int? createdAt,
    int? closedAt,
    int? displayNumber,
  }) {
    return Tab(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      displayNumber: displayNumber ?? this.displayNumber,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'label': label,
        'status': status.dbValue,
        'created_at': createdAt,
        'closed_at': closedAt,
        'display_number': displayNumber,
      };

  factory Tab.fromMap(Map<String, Object?> map) => Tab(
        id: map['id'] as int,
        label: map['label'] as String?,
        status: TabStatus.fromDb(map['status'] as String?),
        createdAt: map['created_at'] as int,
        closedAt: map['closed_at'] as int?,
        displayNumber: map['display_number'] as int?,
      );
}
