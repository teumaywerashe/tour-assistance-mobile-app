import 'package:dio/dio.dart';
import '../models/building.dart';
import '../../core/dio_client.dart';

class BuildingRepository {
  final Dio _dio = DioClient.instance;

  Future<List<Building>> getBuildings({String? search, String? category}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != 'All') params['category'] = category;

    final response = await _dio.get('/api/building', queryParameters: params);
    final data = response.data;
    final list = data is List ? data : (data['buildings'] ?? data['data'] ?? []);
    return (list as List).map((e) => Building.fromJson(e)).toList();
  }

  Future<Building> getBuilding(String id) async {
    final response = await _dio.get('/api/building/$id');
    final data = response.data;
    return Building.fromJson(data is Map ? data : data['building']);
  }

  Future<Building> createBuilding(FormData formData) async {
    final response = await _dio.post('/api/building', data: formData);
    return Building.fromJson(response.data['building'] ?? response.data);
  }

  Future<Building> updateBuilding(String id, FormData formData) async {
    final response = await _dio.put('/api/building/$id', data: formData);
    return Building.fromJson(response.data['building'] ?? response.data);
  }

  Future<void> deleteBuilding(String id) async {
    await _dio.delete('/api/building/$id');
  }
}
