import 'package:yoshlar/data/model/activity.dart';

abstract class ActivityListState {}

class ActivityListInitial extends ActivityListState {}

class ActivityListLoading extends ActivityListState {}

class ActivityListLoaded extends ActivityListState {
  final List<Activity> activities;
  final int total;
  final int currentPage;
  final int lastPage;
  final int? officerFilter;
  final bool isLoadingMore;

  ActivityListLoaded({
    required this.activities,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    this.officerFilter,
    this.isLoadingMore = false,
  });

  bool get hasMorePages => currentPage < lastPage;

  ActivityListLoaded copyWith({
    List<Activity>? activities,
    int? total,
    int? currentPage,
    int? lastPage,
    int? officerFilter,
    bool? isLoadingMore,
  }) {
    return ActivityListLoaded(
      activities: activities ?? this.activities,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      officerFilter: officerFilter ?? this.officerFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ActivityListError extends ActivityListState {
  final String message;
  ActivityListError(this.message);
}
