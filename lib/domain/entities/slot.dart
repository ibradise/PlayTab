enum Slot {
  a,
  b;

  String get dbColumn => this == Slot.a ? 'slot_a_tab_id' : 'slot_b_tab_id';
}
