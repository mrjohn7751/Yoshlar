import 'dart:io';
import 'dart:typed_data';

import 'package:yoshlar/data/model/activity.dart';
import 'package:yoshlar/data/model/comment.dart';
import 'package:yoshlar/data/service/api_client.dart';

class ActivityService {
  final ApiClient _client;

  ActivityService(this._client);

  Future<ActivityListResponse> getAllActivities({
    int page = 1,
    int? officerId,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (officerId != null) params['officer_id'] = officerId.toString();

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _client.get('/activities?$queryString');
    final data = response['data'] as List<dynamic>;
    final meta = response['meta'] as Map<String, dynamic>?;

    return ActivityListResponse(
      activities: data.map((e) => Activity.fromJson(e as Map<String, dynamic>)).toList(),
      total: meta?['total'] ?? data.length,
      lastPage: meta?['last_page'] ?? 1,
      currentPage: meta?['current_page'] ?? 1,
    );
  }

  Future<List<Activity>> getYouthActivities(int youthId, {bool all = true}) async {
    final response = await _client.get('/youths/$youthId/activities${all ? '?all=true' : ''}');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Activity> createActivity(int youthId, Map<String, dynamic> data) async {
    final response = await _client.post('/youths/$youthId/activities', body: data);
    return Activity.fromJson(response['data']);
  }

  Future<Activity> getActivity(int activityId) async {
    final response = await _client.get('/activities/$activityId');
    return Activity.fromJson(response['data']);
  }

  Future<void> uploadImages(int activityId, List<File> images) async {
    await _client.multipartPost(
      '/activities/$activityId/images',
      fileList: images,
      fileFieldName: 'images[]',
    );
  }

  Future<void> uploadImagesFromBytes(int activityId, List<Uint8List> imageBytes) async {
    await _client.multipartPostWithBytesList(
      '/activities/$activityId/images',
      bytesList: imageBytes,
      fileFieldName: 'images[]',
    );
  }

  Future<List<Comment>> getComments(int activityId, {bool all = true}) async {
    final response = await _client.get('/activities/$activityId/comments${all ? '?all=true' : ''}');
    final data = response['data'] as List<dynamic>;
    return data
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Comment> addComment(int activityId, String body) async {
    final response = await _client.post(
      '/activities/$activityId/comments',
      body: {'body': body},
    );
    return Comment.fromJson(response['data']);
  }
}

class ActivityListResponse {
  final List<Activity> activities;
  final int total;
  final int lastPage;
  final int currentPage;

  ActivityListResponse({
    required this.activities,
    required this.total,
    required this.lastPage,
    required this.currentPage,
  });
}
