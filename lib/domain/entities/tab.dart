import 'tab_status.dart';

class Tab {
  const Tab({
    required this.id,
    this.label,
    required this.status,
    required this.createdAt,
    this.closedAt,
  });

  final int id;
  final String? label;
  final TabStatus status;
  final int createdAt;
  final int? closedAt;

  /// Display number is the auto-increment id (#N).
  int get number => id;

  String get displayLabel =>
      (label == null || label!.isEmpty) ? '#$number' : '#$number $label';

  bool get isOpen => status == TabStatus.open;

  Tab copyWith({
    int? id,
    String? label,
    TabStatus? status,
    int? createdAt,
    int? closedAt,
  }) {
    return Tab(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'label': label,
        'status': status.dbValue,
        'created_at': createdAt,
        'closed_at': closedAt,
      };

  factory Tab.fromMap(Map<String, Object?> map) => Tab(
        id: map['id'] as int,
        label: map['label'] as String?,
        status: TabStatus.fromDb(map['status'] as String?),
        createdAt: map['created_at'] as int,
        closedAt: map['closed_at'] as int?,
      );
}
