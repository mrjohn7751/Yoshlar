import 'dart:typed_data';

import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/data/service/api_client.dart';

class OfficerService {
  final ApiClient _client;

  OfficerService(this._client);

  Future<List<OfficerModel>> getOfficers({bool all = true}) async {
    final response = await _client.get('/officers${all ? '?all=true' : ''}');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => OfficerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OfficerModel> getOfficer(int id) async {
    final response = await _client.get('/officers/$id');
    return OfficerModel.fromJson(response['data']);
  }

  Future<OfficerModel> createOfficer(Map<String, dynamic> data, {Uint8List? photoBytes}) async {
    if (photoBytes != null) {
      final fields = data.map((k, v) => MapEntry(k, v.toString()));
      final response = await _client.multipartPostWithBytes(
        '/officers',
        fields: fields,
        fileBytes: {'photo': photoBytes},
      );
      return OfficerModel.fromJson(response['data']);
    }
    final response = await _client.post('/officers', body: data);
    return OfficerModel.fromJson(response['data']);
  }

  /// Creates officer and returns both the officer and generated credentials
  Future<Map<String, dynamic>> createOfficerWithCredentials(
    Map<String, dynamic> data, {
    Uint8List? photoBytes,
  }) async {
    Map<String, dynamic> response;
    if (photoBytes != null) {
      final fields = data.map((k, v) => MapEntry(k, v.toString()));
      response = await _client.multipartPostWithBytes(
        '/officers',
        fields: fields,
        fileBytes: {'photo': photoBytes},
      );
    } else {
      response = await _client.post('/officers', body: data);
    }
    return {
      'officer': OfficerModel.fromJson(response['data']),
      'credentials': response['credentials'],
    };
  }

  Future<OfficerModel> updateOfficer(int id, Map<String, dynamic> data, {Uint8List? photoBytes}) async {
    if (photoBytes != null) {
      final fields = data.map((k, v) => MapEntry(k, v.toString()));
      final response = await _client.multipartPostWithBytes(
        '/officers/$id',
        fields: fields,
        fileBytes: {'photo': photoBytes},
      );
      return OfficerModel.fromJson(response['data']);
    }
    final response = await _client.post('/officers/$id', body: data);
    return OfficerModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> resetPassword(int officerId) async {
    final response = await _client.post('/officers/$officerId/reset-password');
    return response['credentials'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generateCredentials(int officerId) async {
    final response = await _client.post('/officers/$officerId/generate-credentials');
    return response['credentials'] as Map<String, dynamic>;
  }

  Future<void> deleteOfficer(int id) async {
    await _client.delete('/officers/$id');
  }

  Future<List<UserModel>> getOfficerYouths(int officerId, {bool all = true}) async {
    final response = await _client.get('/officers/$officerId/youths${all ? '?all=true' : ''}');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> attachYouths(int officerId, List<int> youthIds) async {
    await _client.post('/officers/$officerId/attach-youths', body: {
      'youth_ids': youthIds,
    });
  }

  Future<void> detachYouths(int officerId, List<int> youthIds) async {
    await _client.post('/officers/$officerId/detach-youths', body: {
      'youth_ids': youthIds,
    });
  }
}
