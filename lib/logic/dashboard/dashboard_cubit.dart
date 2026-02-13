import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/dashboard_service.dart';
import 'package:yoshlar/logic/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardService _dashboardService;

  DashboardCubit(this._dashboardService) : super(DashboardInitial());

  Future<void> loadDashboard() async {
    try {
      emit(DashboardLoading());
      final results = await Future.wait([
        _dashboardService.getStats(),
        _dashboardService.getRegions(),
        _dashboardService.getCategories(),
      ]);
      emit(DashboardLoaded(
        stats: results[0] as dynamic,
        regions: results[1] as dynamic,
        categories: results[2] as dynamic,
      ));
    } catch (e) {
      emit(DashboardError(safeErrorMessage(e)));
    }
  }
}
