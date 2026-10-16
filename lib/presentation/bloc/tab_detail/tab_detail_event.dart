part of 'tab_detail_bloc.dart';

sealed class TabDetailEvent extends Equatable {
  const TabDetailEvent();

  @override
  List<Object?> get props => [];
}

class TabDetailLoadRequested extends TabDetailEvent {
  const TabDetailLoadRequested();
}

class MarkPaidRequested extends TabDetailEvent {
  const MarkPaidRequested({required this.close});

  final bool close;

  @override
  List<Object?> get props => [close];
}

class CloseTabRequested extends TabDetailEvent {
  const CloseTabRequested();
}

class LabelEditRequested extends TabDetailEvent {
  const LabelEditRequested(this.label);

  final String label;

  @override
  List<Object?> get props => [label];
}

class PaymentActionConsumed extends TabDetailEvent {
  const PaymentActionConsumed();
}
