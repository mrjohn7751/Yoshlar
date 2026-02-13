import 'package:yoshlar/data/model/category.dart';
import 'package:yoshlar/data/model/dashboard_stats.dart';
import 'package:yoshlar/data/model/region.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<RegionModel> regions;
  final List<CategoryModel> categories;

  DashboardLoaded({
    required this.stats,
    required this.regions,
    required this.categories,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
