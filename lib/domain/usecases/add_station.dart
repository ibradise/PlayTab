import '../exceptions.dart';
import '../repositories/station_repository.dart';

class AddStation {
  AddStation(this._stations);

  final StationRepository _stations;

  Future<int> call(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Station name cannot be empty');
    }
    return _stations.create(trimmed);
  }
}
