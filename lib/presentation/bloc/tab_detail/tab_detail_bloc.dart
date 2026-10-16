import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/payment_action.dart';
import '../../../domain/entities/tab_detail.dart';
import '../../../domain/repositories/tab_repository.dart';
import '../../../domain/usecases/close_tab.dart';
import '../../../domain/usecases/get_tab_detail.dart';
import '../../../domain/usecases/mark_paid.dart';

part 'tab_detail_event.dart';
part 'tab_detail_state.dart';

class TabDetailBloc extends Bloc<TabDetailEvent, TabDetailState> {
  TabDetailBloc({
    required this.tabId,
    required this.getTabDetail,
    required this.markPaid,
    required this.closeTab,
    required this.tabs,
  }) : super(const TabDetailState()) {
    on<TabDetailLoadRequested>(_onLoad);
    on<MarkPaidRequested>(_onMarkPaid);
    on<CloseTabRequested>(_onClose);
    on<LabelEditRequested>(_onEditLabel);
    on<PaymentActionConsumed>(_onConsumed);
  }

  final int tabId;
  final GetTabDetail getTabDetail;
  final MarkPaid markPaid;
  final CloseTab closeTab;
  final TabRepository tabs;

  Future<void> _onLoad(
    TabDetailLoadRequested event,
    Emitter<TabDetailState> emit,
  ) async {
    emit(const TabDetailState(loading: true));
    try {
      emit(TabDetailState(detail: await getTabDetail(tabId)));
    } catch (e) {
      emit(TabDetailState(error: e.toString()));
    }
  }

  Future<void> _onMarkPaid(
    MarkPaidRequested event,
    Emitter<TabDetailState> emit,
  ) async {
    try {
      await markPaid(tabId: tabId, close: event.close);
      final detail = await getTabDetail(tabId);
      emit(TabDetailState(
        detail: detail,
        lastPaymentAction:
            event.close ? PaymentAction.closeTab : PaymentAction.keepOpen,
      ));
    } catch (e) {
      emit(TabDetailState(error: e.toString(), detail: state.detail));
    }
  }

  Future<void> _onClose(
    CloseTabRequested event,
    Emitter<TabDetailState> emit,
  ) async {
    try {
      await closeTab(tabId);
      emit(const TabDetailState(lastPaymentAction: PaymentAction.closeTab));
    } catch (e) {
      emit(TabDetailState(error: e.toString(), detail: state.detail));
    }
  }

  Future<void> _onEditLabel(
    LabelEditRequested event,
    Emitter<TabDetailState> emit,
  ) async {
    try {
      await tabs.updateLabel(tabId, event.label);
      emit(TabDetailState(detail: await getTabDetail(tabId)));
    } catch (e) {
      emit(TabDetailState(error: e.toString(), detail: state.detail));
    }
  }

  void _onConsumed(
    PaymentActionConsumed event,
    Emitter<TabDetailState> emit,
  ) {
    emit(TabDetailState(detail: state.detail));
  }
}
