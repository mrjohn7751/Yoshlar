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
  final int regionsCurrentPage;
  final int regionsLastPage;
  final int categoriesCurrentPage;
  final int categoriesLastPage;
  final bool isLoadingMoreRegions;
  final bool isLoadingMoreCategories;

  DashboardLoaded({
    required this.stats,
    required this.regions,
    required this.categories,
    this.regionsCurrentPage = 1,
    this.regionsLastPage = 1,
    this.categoriesCurrentPage = 1,
    this.categoriesLastPage = 1,
    this.isLoadingMoreRegions = false,
    this.isLoadingMoreCategories = false,
  });

  bool get hasMoreRegions => regionsCurrentPage < regionsLastPage;
  bool get hasMoreCategories => categoriesCurrentPage < categoriesLastPage;

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<RegionModel>? regions,
    List<CategoryModel>? categories,
    int? regionsCurrentPage,
    int? regionsLastPage,
    int? categoriesCurrentPage,
    int? categoriesLastPage,
    bool? isLoadingMoreRegions,
    bool? isLoadingMoreCategories,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      regions: regions ?? this.regions,
      categories: categories ?? this.categories,
      regionsCurrentPage: regionsCurrentPage ?? this.regionsCurrentPage,
      regionsLastPage: regionsLastPage ?? this.regionsLastPage,
      categoriesCurrentPage: categoriesCurrentPage ?? this.categoriesCurrentPage,
      categoriesLastPage: categoriesLastPage ?? this.categoriesLastPage,
      isLoadingMoreRegions: isLoadingMoreRegions ?? this.isLoadingMoreRegions,
      isLoadingMoreCategories: isLoadingMoreCategories ?? this.isLoadingMoreCategories,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
