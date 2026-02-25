import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/model/dashboard_stats.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/cache_service.dart';
import 'package:yoshlar/data/service/dashboard_service.dart';
import 'package:yoshlar/logic/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardService _dashboardService;
  final CacheService _cacheService;

  DashboardCubit(this._dashboardService, this._cacheService)
      : super(DashboardInitial());

  Future<void> loadDashboard() async {
    try {
      emit(DashboardLoading());

      // 1. Avval keshdan o'qish - tez UI ko'rsatish
      final cachedRegions = await _cacheService.getCachedRegions();
      final cachedCategories = await _cacheService.getCachedCategories();

      if (cachedRegions != null && cachedCategories != null) {
        emit(DashboardLoaded(
          stats: DashboardStats(jamiYoshlar: 0, ogilBolalar: 0, qizBolalar: 0),
          regions: cachedRegions,
          categories: cachedCategories,
        ));
      }

      // 2. API dan yangi ma'lumot olish (pagination bilan)
      final results = await Future.wait([
        _dashboardService.getStats(),
        _dashboardService.getRegionsPaginated(page: 1, perPage: 10),
        _dashboardService.getCategoriesPaginated(page: 1, perPage: 10),
      ]);

      final stats = results[0] as DashboardStats;
      final regionResult = results[1] as PaginatedResult;
      final categoryResult = results[2] as PaginatedResult;

      // 3. Keshga saqlash
      await _cacheService.cacheRegions(regionResult.data.cast());
      await _cacheService.cacheCategories(categoryResult.data.cast());

      // 4. Yangi ma'lumot bilan yangilash
      emit(DashboardLoaded(
        stats: stats,
        regions: regionResult.data.cast(),
        categories: categoryResult.data.cast(),
        regionsCurrentPage: regionResult.currentPage,
        regionsLastPage: regionResult.lastPage,
        categoriesCurrentPage: categoryResult.currentPage,
        categoriesLastPage: categoryResult.lastPage,
      ));
    } catch (e) {
      // Xato bo'lsa, keshdan ko'rsatishga harakat qilish
      final cachedRegions = await _cacheService.getCachedRegions();
      final cachedCategories = await _cacheService.getCachedCategories();

      if (cachedRegions != null && cachedCategories != null) {
        emit(DashboardLoaded(
          stats: DashboardStats(jamiYoshlar: 0, ogilBolalar: 0, qizBolalar: 0),
          regions: cachedRegions,
          categories: cachedCategories,
        ));
      } else {
        emit(DashboardError(safeErrorMessage(e)));
      }
    }
  }

  Future<void> loadMoreRegions() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;
    if (!currentState.hasMoreRegions || currentState.isLoadingMoreRegions) return;

    emit(currentState.copyWith(isLoadingMoreRegions: true));

    try {
      final result = await _dashboardService.getRegionsPaginated(
        page: currentState.regionsCurrentPage + 1,
        perPage: 10,
      );

      final updatedRegions = [...currentState.regions, ...result.data];
      await _cacheService.cacheRegions(updatedRegions);

      emit(currentState.copyWith(
        regions: updatedRegions,
        regionsCurrentPage: result.currentPage,
        regionsLastPage: result.lastPage,
        isLoadingMoreRegions: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMoreRegions: false));
    }
  }

  Future<void> loadMoreCategories() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;
    if (!currentState.hasMoreCategories || currentState.isLoadingMoreCategories) return;

    emit(currentState.copyWith(isLoadingMoreCategories: true));

    try {
      final result = await _dashboardService.getCategoriesPaginated(
        page: currentState.categoriesCurrentPage + 1,
        perPage: 10,
      );

      final updatedCategories = [...currentState.categories, ...result.data];
      await _cacheService.cacheCategories(updatedCategories);

      emit(currentState.copyWith(
        categories: updatedCategories,
        categoriesCurrentPage: result.currentPage,
        categoriesLastPage: result.lastPage,
        isLoadingMoreCategories: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMoreCategories: false));
    }
  }
}
