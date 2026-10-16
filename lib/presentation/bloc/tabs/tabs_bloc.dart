import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/tab_with_owed.dart';
import '../../../domain/repositories/tab_repository.dart';
import '../../../domain/usecases/get_open_tabs.dart';

part 'tabs_event.dart';
part 'tabs_state.dart';

class TabsBloc extends Bloc<TabsEvent, TabsState> {
  TabsBloc({required this.tabs, required this.getOpenTabs})
      : super(const TabsState()) {
    on<TabsLoadRequested>(_onLoad);
    on<TabCreateRequested>(_onCreate);
    on<TabLabelUpdated>(_onUpdateLabel);
  }

  final TabRepository tabs;
  final GetOpenTabs getOpenTabs;

  Future<void> _onLoad(
    TabsLoadRequested event,
    Emitter<TabsState> emit,
  ) async {
    emit(const TabsState(loading: true));
    try {
      emit(TabsState(tabs: await getOpenTabs()));
    } catch (e) {
      emit(TabsState(error: e.toString()));
    }
  }

  Future<void> _onCreate(
    TabCreateRequested event,
    Emitter<TabsState> emit,
  ) async {
    try {
      await tabs.create(label: event.label);
      add(const TabsLoadRequested());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateLabel(
    TabLabelUpdated event,
    Emitter<TabsState> emit,
  ) async {
    try {
      await tabs.updateLabel(event.id, event.label);
      add(const TabsLoadRequested());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
