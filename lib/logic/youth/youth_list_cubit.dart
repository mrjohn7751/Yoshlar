import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/youth_service.dart';
import 'package:yoshlar/logic/youth/youth_list_state.dart';

class YouthListCubit extends Cubit<YouthListState> {
  final YouthService _youthService;

  String? _regionFilter;
  String? _genderFilter;
  String? _searchQuery;
  int? _officerFilter;

  YouthListCubit(this._youthService) : super(YouthListInitial());

  Future<void> loadYouths({int page = 1}) async {
    try {
      emit(YouthListLoading());
      final response = await _youthService.getYouths(
        page: page,
        region: _regionFilter,
        gender: _genderFilter,
        search: _searchQuery,
        officerId: _officerFilter,
      );
      emit(YouthListLoaded(
        youths: response.youths,
        total: response.total,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        regionFilter: _regionFilter,
        genderFilter: _genderFilter,
      ));
    } catch (e) {
      emit(YouthListError(safeErrorMessage(e)));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! YouthListLoaded || current.isLoadingMore || !current.hasMorePages) {
      return;
    }

    try {
      emit(current.copyWith(isLoadingMore: true));
      final response = await _youthService.getYouths(
        page: current.currentPage + 1,
        region: _regionFilter,
        gender: _genderFilter,
        search: _searchQuery,
        officerId: _officerFilter,
      );
      emit(YouthListLoaded(
        youths: [...current.youths, ...response.youths],
        total: response.total,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        regionFilter: _regionFilter,
        genderFilter: _genderFilter,
      ));
    } catch (e) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  void setRegionFilter(String? region) {
    _regionFilter = region;
    loadYouths();
  }

  void setGenderFilter(String? gender) {
    _genderFilter = gender;
    loadYouths();
  }

  void setOfficerFilter(int? officerId) {
    _officerFilter = officerId;
    loadYouths();
  }

  void search(String? query) {
    _searchQuery = (query != null && query.isEmpty) ? null : query;
    loadYouths();
  }

  Future<void> createYouth(Map<String, dynamic> data, {Uint8List? imageBytes}) async {
    await _youthService.createYouth(data, imageBytes: imageBytes);
    loadYouths();
  }

  Future<void> updateYouth(int id, Map<String, dynamic> data, {Uint8List? imageBytes}) async {
    await _youthService.updateYouth(id, data, imageBytes: imageBytes);
    loadYouths();
  }

  Future<void> deleteYouth(int id) async {
    await _youthService.deleteYouth(id);
    loadYouths();
  }
}
