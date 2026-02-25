import 'package:yoshlar/data/model/category.dart';
import 'package:yoshlar/data/model/dashboard_stats.dart';
import 'package:yoshlar/data/model/region.dart';
import 'package:yoshlar/data/service/api_client.dart';

class PaginatedResult<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedResult({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;
}

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

  Future<PaginatedResult<RegionModel>> getRegionsPaginated({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _client.get(
      '/dashboard/regions?page=$page&per_page=$perPage',
    );
    final data = response['data'] as List<dynamic>;
    final meta = response['meta'] as Map<String, dynamic>;
    return PaginatedResult(
      data: data
          .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? 0,
    );
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get('/dashboard/categories');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaginatedResult<CategoryModel>> getCategoriesPaginated({
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _client.get(
      '/dashboard/categories?page=$page&per_page=$perPage',
    );
    final data = response['data'] as List<dynamic>;
    final meta = response['meta'] as Map<String, dynamic>;
    return PaginatedResult(
      data: data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? 0,
    );
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
