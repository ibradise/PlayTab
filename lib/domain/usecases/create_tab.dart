import '../entities/tab.dart';
import '../repositories/tab_repository.dart';

class CreateTab {
  CreateTab(this._tabs);

  final TabRepository _tabs;

  Future<Tab> call({String? label}) => _tabs.create(label: label);
}
