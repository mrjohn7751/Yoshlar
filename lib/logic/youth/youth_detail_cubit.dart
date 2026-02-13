import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/activity_service.dart';
import 'package:yoshlar/data/service/youth_service.dart';
import 'package:yoshlar/logic/youth/youth_detail_state.dart';

class YouthDetailCubit extends Cubit<YouthDetailState> {
  final YouthService _youthService;
  final ActivityService _activityService;

  int? _currentYouthId;

  YouthDetailCubit(this._youthService, this._activityService)
      : super(YouthDetailInitial());

  Future<void> loadYouthDetail(int youthId) async {
    try {
      _currentYouthId = youthId;
      emit(YouthDetailLoading());
      final results = await Future.wait([
        _youthService.getYouth(youthId),
        _activityService.getYouthActivities(youthId),
      ]);
      emit(YouthDetailLoaded(
        youth: results[0] as dynamic,
        activities: results[1] as dynamic,
      ));
    } catch (e) {
      emit(YouthDetailError(safeErrorMessage(e)));
    }
  }

  Future<void> createActivity(Map<String, dynamic> data, {List<Uint8List>? imageBytes}) async {
    if (_currentYouthId == null) return;
    final activity = await _activityService.createActivity(_currentYouthId!, data);
    if (imageBytes != null && imageBytes.isNotEmpty && activity.id != null) {
      await _activityService.uploadImagesFromBytes(activity.id!, imageBytes);
    }
    loadYouthDetail(_currentYouthId!);
  }
}

class ActivityDetailCubit extends Cubit<ActivityDetailState> {
  final ActivityService _activityService;

  int? _currentActivityId;

  ActivityDetailCubit(this._activityService) : super(ActivityDetailInitial());

  Future<void> loadActivityDetail(int activityId) async {
    try {
      _currentActivityId = activityId;
      emit(ActivityDetailLoading());
      final results = await Future.wait([
        _activityService.getActivity(activityId),
        _activityService.getComments(activityId),
      ]);
      emit(ActivityDetailLoaded(
        activity: results[0] as dynamic,
        comments: results[1] as dynamic,
      ));
    } catch (e) {
      emit(ActivityDetailError(safeErrorMessage(e)));
    }
  }

  Future<void> addComment(String body) async {
    if (_currentActivityId == null) return;
    await _activityService.addComment(_currentActivityId!, body);
    loadActivityDetail(_currentActivityId!);
  }
}
