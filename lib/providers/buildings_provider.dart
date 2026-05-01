import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/building.dart';
import '../data/repositories/building_repository.dart';

class BuildingsNotifier extends AsyncNotifier<List<Building>> {
  final _repo = BuildingRepository();
  String? _lastSearch;
  String? _lastCategory;

  @override
  Future<List<Building>> build() async {
    return _repo.getBuildings();
  }

  Future<void> fetchBuildings({String? search, String? category}) async {
    _lastSearch = search;
    _lastCategory = category;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.getBuildings(search: search, category: category),
    );
  }

  Future<void> refresh() async {
    await fetchBuildings(search: _lastSearch, category: _lastCategory);
  }

  Future<void> deleteBuilding(String id) async {
    await _repo.deleteBuilding(id);
    await refresh();
  }
}

final buildingsProvider =
    AsyncNotifierProvider<BuildingsNotifier, List<Building>>(
        BuildingsNotifier.new);

final selectedBuildingProvider = StateProvider<Building?>((ref) => null);
