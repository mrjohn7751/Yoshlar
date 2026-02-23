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

      // 2. API dan yangi ma'lumot olish
      final results = await Future.wait([
        _dashboardService.getStats(),
        _dashboardService.getRegions(),
        _dashboardService.getCategories(),
      ]);

      final regions = results[1] as dynamic;
      final categories = results[2] as dynamic;

      // 3. Keshga saqlash
      await _cacheService.cacheRegions(regions);
      await _cacheService.cacheCategories(categories);

      // 4. Yangi ma'lumot bilan yangilash
      emit(DashboardLoaded(
        stats: results[0] as dynamic,
        regions: regions,
        categories: categories,
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
}
