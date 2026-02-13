import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/model/user.dart';

abstract class OfficerState {}

class OfficerInitial extends OfficerState {}

class OfficerLoading extends OfficerState {}

class OfficerListLoaded extends OfficerState {
  final List<OfficerModel> officers;
  OfficerListLoaded(this.officers);
}

class OfficerYouthsLoaded extends OfficerState {
  final OfficerModel? officer;
  final List<UserModel> youths;
  OfficerYouthsLoaded({this.officer, required this.youths});
}

class OfficerError extends OfficerState {
  final String message;
  OfficerError(this.message);
}
