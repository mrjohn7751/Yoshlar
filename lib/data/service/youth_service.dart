import 'dart:typed_data';

import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/data/service/api_client.dart';

class YouthService {
  final ApiClient _client;

  YouthService(this._client);

  Future<YouthListResponse> getYouths({
    int page = 1,
    String? region,
    String? gender,
    String? category,
    String? search,
    int? officerId,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (region != null && region.isNotEmpty) params['region'] = region;
    if (gender != null && gender.isNotEmpty) params['gender'] = gender;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (officerId != null) params['officer_id'] = officerId.toString();

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _client.get('/youths?$queryString');
    final data = response['data'] as List<dynamic>;
    final meta = response['meta'] as Map<String, dynamic>?;

    return YouthListResponse(
      youths: data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta?['total'] ?? data.length,
      lastPage: meta?['last_page'] ?? 1,
      currentPage: meta?['current_page'] ?? 1,
    );
  }

  /// Fetches all youths (no pagination) for selection dialogs.
  Future<List<UserModel>> getAllYouths() async {
    final response = await _client.get('/youths?all=true');
    final data = response['data'] as List<dynamic>;
    return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<UserModel> getYouth(int id) async {
    final response = await _client.get('/youths/$id');
    return UserModel.fromJson(response['data']);
  }

  Map<String, String> _toMultipartFields(Map<String, dynamic> data) {
    final fields = <String, String>{};
    data.forEach((k, v) {
      if (v == null) return;
      if (v is List) {
        for (int i = 0; i < v.length; i++) {
          fields['$k[$i]'] = v[i].toString();
        }
      } else {
        fields[k] = v.toString();
      }
    });
    return fields;
  }

  Future<Map<String, dynamic>> createYouthRaw(Map<String, dynamic> data, {Uint8List? imageBytes}) async {
    if (imageBytes != null) {
      return await _client.multipartPostWithBytes(
        '/youths',
        fields: _toMultipartFields(data),
        fileBytes: {'image': imageBytes},
      );
    }
    return await _client.post('/youths', body: data);
  }

  Future<UserModel> createYouth(Map<String, dynamic> data, {Uint8List? imageBytes}) async {
    final response = await createYouthRaw(data, imageBytes: imageBytes);
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> updateYouth(int id, Map<String, dynamic> data, {Uint8List? imageBytes}) async {
    if (imageBytes != null) {
      final response = await _client.multipartPostWithBytes(
        '/youths/$id',
        fields: _toMultipartFields(data),
        fileBytes: {'image': imageBytes},
      );
      return UserModel.fromJson(response['data']);
    }
    final response = await _client.post('/youths/$id', body: data);
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> updateYouthPhoto(int youthId, Uint8List imageBytes) async {
    final response = await _client.multipartPostWithBytes(
      '/youths/$youthId/photo',
      fileBytes: {'image': imageBytes},
    );
    return UserModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> bulkImportYouths(List<Map<String, dynamic>> youths) async {
    final response = await _client.post('/youths/import', body: {'youths': youths});
    return response;
  }

  Future<void> deleteYouth(int id) async {
    await _client.delete('/youths/$id');
  }
}

class YouthListResponse {
  final List<UserModel> youths;
  final int total;
  final int lastPage;
  final int currentPage;

  YouthListResponse({
    required this.youths,
    required this.total,
    required this.lastPage,
    required this.currentPage,
  });
}
