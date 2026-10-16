enum TabStatus {
  open,
  closed;

  String get dbValue => name;

  static TabStatus fromDb(String? value) =>
      TabStatus.values.firstWhere((s) => s.name == value, orElse: () => TabStatus.open);
}
