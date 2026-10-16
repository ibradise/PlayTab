part of 'stations_bloc.dart';

class StationsState extends Equatable {
  const StationsState({
    this.loading = false,
    this.stations = const [],
    this.error,
  });

  final bool loading;
  final List<StationWithTabs> stations;
  final String? error;

  @override
  List<Object?> get props => [loading, stations, error];
}
