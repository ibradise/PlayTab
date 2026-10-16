part of 'stations_bloc.dart';

class StationsState extends Equatable {
  const StationsState({
    this.loading = false,
    this.stations = const [],
    this.error,
    this.lastOutcome,
  });

  final bool loading;
  final List<StationWithTabs> stations;
  final String? error;
  final RecordGameOutcome? lastOutcome;

  @override
  List<Object?> get props => [loading, stations, error, lastOutcome];
}
