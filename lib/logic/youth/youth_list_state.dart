import 'package:yoshlar/data/model/user.dart';

abstract class YouthListState {}

class YouthListInitial extends YouthListState {}

class YouthListLoading extends YouthListState {}

class YouthListLoaded extends YouthListState {
  final List<UserModel> youths;
  final int total;
  final int currentPage;
  final int lastPage;
  final String? regionFilter;
  final String? genderFilter;
  final bool isLoadingMore;

  YouthListLoaded({
    required this.youths,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    this.regionFilter,
    this.genderFilter,
    this.isLoadingMore = false,
  });

  bool get hasMorePages => currentPage < lastPage;

  YouthListLoaded copyWith({
    List<UserModel>? youths,
    int? total,
    int? currentPage,
    int? lastPage,
    String? regionFilter,
    String? genderFilter,
    bool? isLoadingMore,
  }) {
    return YouthListLoaded(
      youths: youths ?? this.youths,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      regionFilter: regionFilter ?? this.regionFilter,
      genderFilter: genderFilter ?? this.genderFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class YouthListError extends YouthListState {
  final String message;
  YouthListError(this.message);
}
