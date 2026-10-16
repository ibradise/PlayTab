part of 'tabs_bloc.dart';

sealed class TabsEvent extends Equatable {
  const TabsEvent();

  @override
  List<Object?> get props => [];
}

class TabsLoadRequested extends TabsEvent {
  const TabsLoadRequested();
}

class TabCreateRequested extends TabsEvent {
  const TabCreateRequested(this.label);

  final String? label;

  @override
  List<Object?> get props => [label];
}

class TabLabelUpdated extends TabsEvent {
  const TabLabelUpdated(this.id, this.label);

  final int id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}
