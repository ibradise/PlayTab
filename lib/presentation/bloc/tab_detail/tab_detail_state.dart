part of 'tab_detail_bloc.dart';

class TabDetailState extends Equatable {
  const TabDetailState({
    this.loading = false,
    this.detail,
    this.error,
    this.lastPaymentAction,
  });

  final bool loading;
  final TabDetail? detail;
  final String? error;
  final PaymentAction? lastPaymentAction;

  @override
  List<Object?> get props => [loading, detail, error, lastPaymentAction];
}
