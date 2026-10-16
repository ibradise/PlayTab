part of 'tabs_bloc.dart';

class TabsState extends Equatable {
  const TabsState({this.loading = false, this.tabs = const [], this.error});

  final bool loading;
  final List<TabWithOwed> tabs;
  final String? error;

  int get totalOwed => tabs.fold(0, (sum, t) => sum + t.owed);

  TabsState copyWith({
    bool? loading,
    List<TabWithOwed>? tabs,
    String? error,
  }) {
    return TabsState(
      loading: loading ?? this.loading,
      tabs: tabs ?? this.tabs,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, tabs, error];
}
