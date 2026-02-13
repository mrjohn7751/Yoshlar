import 'package:yoshlar/data/model/category.dart';
import 'package:yoshlar/data/model/dashboard_stats.dart';
import 'package:yoshlar/data/model/region.dart';
import 'package:yoshlar/data/service/api_client.dart';

class DashboardService {
  final ApiClient _client;

  DashboardService(this._client);

  Future<DashboardStats> getStats() async {
    final response = await _client.get('/dashboard/stats');
    return DashboardStats.fromJson(response);
  }

  Future<List<RegionModel>> getRegions() async {
    final response = await _client.get('/dashboard/regions');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get('/dashboard/categories');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getAllRegions() async {
    final response = await _client.get('/regions');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final response = await _client.get('/categories');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
