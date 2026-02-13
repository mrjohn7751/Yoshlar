import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/activity_service.dart';
import 'package:yoshlar/logic/activity/activity_list_state.dart';

class ActivityListCubit extends Cubit<ActivityListState> {
  final ActivityService _activityService;

  int? _officerFilter;

  ActivityListCubit(this._activityService) : super(ActivityListInitial());

  Future<void> loadActivities({int page = 1}) async {
    try {
      emit(ActivityListLoading());
      final response = await _activityService.getAllActivities(
        page: page,
        officerId: _officerFilter,
      );
      emit(ActivityListLoaded(
        activities: response.activities,
        total: response.total,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        officerFilter: _officerFilter,
      ));
    } catch (e) {
      emit(ActivityListError(safeErrorMessage(e)));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ActivityListLoaded || current.isLoadingMore || !current.hasMorePages) {
      return;
    }

    try {
      emit(current.copyWith(isLoadingMore: true));
      final response = await _activityService.getAllActivities(
        page: current.currentPage + 1,
        officerId: _officerFilter,
      );
      emit(ActivityListLoaded(
        activities: [...current.activities, ...response.activities],
        total: response.total,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        officerFilter: _officerFilter,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  void setOfficerFilter(int? officerId) {
    _officerFilter = officerId;
    loadActivities();
  }
}
