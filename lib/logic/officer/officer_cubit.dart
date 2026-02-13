import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/officer_service.dart';
import 'package:yoshlar/data/service/youth_service.dart';
import 'package:yoshlar/logic/officer/officer_state.dart';

class OfficerCubit extends Cubit<OfficerState> {
  final OfficerService _officerService;
  final YouthService _youthService;

  OfficerCubit(this._officerService, this._youthService) : super(OfficerInitial());

  Future<void> loadOfficers() async {
    try {
      emit(OfficerLoading());
      final officers = await _officerService.getOfficers();
      emit(OfficerListLoaded(officers));
    } catch (e) {
      emit(OfficerError(safeErrorMessage(e)));
    }
  }

  /// Load officers, find the one matching userId, then load their youths
  Future<void> loadMyYouths(int userId) async {
    try {
      emit(OfficerLoading());
      final officers = await _officerService.getOfficers();
      final myOfficer = officers.cast<OfficerModel?>().firstWhere(
        (o) => o!.userId == userId,
        orElse: () => null,
      );
      if (myOfficer == null) {
        emit(OfficerYouthsLoaded(officer: null, youths: []));
        return;
      }
      final youths = await _officerService.getOfficerYouths(myOfficer.id);
      emit(OfficerYouthsLoaded(officer: myOfficer, youths: youths));
    } catch (e) {
      emit(OfficerError(safeErrorMessage(e)));
    }
  }

  Future<Map<String, dynamic>?> createOfficer(Map<String, dynamic> data, {Uint8List? photoBytes}) async {
    final result = await _officerService.createOfficerWithCredentials(data, photoBytes: photoBytes);
    loadOfficers();
    return result['credentials'] as Map<String, dynamic>?;
  }

  Future<void> updateOfficer(int id, Map<String, dynamic> data, {Uint8List? photoBytes}) async {
    await _officerService.updateOfficer(id, data, photoBytes: photoBytes);
    loadOfficers();
  }

  Future<void> deleteOfficer(int id) async {
    await _officerService.deleteOfficer(id);
    loadOfficers();
  }

  Future<void> loadOfficerYouths(int officerId) async {
    try {
      emit(OfficerLoading());
      final officer = await _officerService.getOfficer(officerId);
      final youths = await _officerService.getOfficerYouths(officerId);
      emit(OfficerYouthsLoaded(officer: officer, youths: youths));
    } catch (e) {
      emit(OfficerError(safeErrorMessage(e)));
    }
  }

  Future<void> attachYouths(int officerId, List<int> youthIds) async {
    await _officerService.attachYouths(officerId, youthIds);
    loadOfficerYouths(officerId);
  }

  Future<void> detachYouths(int officerId, List<int> youthIds) async {
    await _officerService.detachYouths(officerId, youthIds);
    loadOfficerYouths(officerId);
  }

  Future<List<UserModel>> getUnattachedYouths(int officerId) async {
    final allYouths = await _youthService.getAllYouths();
    final officerYouths = await _officerService.getOfficerYouths(officerId);
    final officerYouthIds = officerYouths.map((y) => y.id).toSet();
    return allYouths.where((y) => !officerYouthIds.contains(y.id)).toList();
  }
}
