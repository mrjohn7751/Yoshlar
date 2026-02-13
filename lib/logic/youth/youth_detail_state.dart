import 'package:yoshlar/data/model/activity.dart';
import 'package:yoshlar/data/model/comment.dart';
import 'package:yoshlar/data/model/user.dart';

abstract class YouthDetailState {}

class YouthDetailInitial extends YouthDetailState {}

class YouthDetailLoading extends YouthDetailState {}

class YouthDetailLoaded extends YouthDetailState {
  final UserModel youth;
  final List<Activity> activities;

  YouthDetailLoaded({required this.youth, required this.activities});
}

class YouthDetailError extends YouthDetailState {
  final String message;
  YouthDetailError(this.message);
}

// Activity detail states
abstract class ActivityDetailState {}

class ActivityDetailInitial extends ActivityDetailState {}

class ActivityDetailLoading extends ActivityDetailState {}

class ActivityDetailLoaded extends ActivityDetailState {
  final Activity activity;
  final List<Comment> comments;

  ActivityDetailLoaded({required this.activity, required this.comments});
}

class ActivityDetailError extends ActivityDetailState {
  final String message;
  ActivityDetailError(this.message);
}
