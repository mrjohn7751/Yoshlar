import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoshlar/data/service/activity_service.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/auth_service.dart';
import 'package:yoshlar/data/service/cache_service.dart';
import 'package:yoshlar/data/service/dashboard_service.dart';
import 'package:yoshlar/data/service/face_compare_service.dart';
import 'package:yoshlar/data/service/officer_service.dart';
import 'package:yoshlar/data/service/youth_service.dart';
import 'package:yoshlar/logic/activity/activity_list_cubit.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/dashboard/dashboard_cubit.dart';
import 'package:yoshlar/logic/officer/officer_cubit.dart';
import 'package:yoshlar/logic/youth/youth_detail_cubit.dart';
import 'package:yoshlar/logic/youth/youth_list_cubit.dart';
import 'package:yoshlar/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final apiClient = ApiClient(storage);
  final prefs = await SharedPreferences.getInstance();
  final cacheService = CacheService(prefs);
  await apiClient.init();
  runApp(MyApp(apiClient: apiClient, cacheService: cacheService));
}

class MyApp extends StatefulWidget {
  final ApiClient apiClient;
  final CacheService cacheService;
  const MyApp({super.key, required this.apiClient, required this.cacheService});

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  late final AuthService _authService;
  late final YouthService _youthService;
  late final OfficerService _officerService;
  late final ActivityService _activityService;
  late final DashboardService _dashboardService;
  late final FaceCompareService _faceCompareService;
  late final AuthCubit _authCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(widget.apiClient);
    _youthService = YouthService(widget.apiClient);
    _officerService = OfficerService(widget.apiClient);
    _activityService = ActivityService(widget.apiClient);
    _dashboardService = DashboardService(widget.apiClient);
    _faceCompareService = FaceCompareService(widget.apiClient);
    _authCubit = AuthCubit(_authService, widget.cacheService);
    _appRouter = AppRouter(_authCubit);

    widget.apiClient.onUnauthorized = () => _authCubit.forceLogout();

    // Darhol auth tekshirish - splash kerak emas
    _authCubit.checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authService),
        RepositoryProvider.value(value: _faceCompareService),
        RepositoryProvider.value(value: _officerService),
        RepositoryProvider.value(value: _youthService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider(
            create: (_) =>
                DashboardCubit(_dashboardService, widget.cacheService),
          ),
          BlocProvider(create: (_) => YouthListCubit(_youthService)),
          BlocProvider(
            create: (_) => YouthDetailCubit(_youthService, _activityService),
          ),
          BlocProvider(create: (_) => ActivityDetailCubit(_activityService)),
          BlocProvider(
            create: (_) => OfficerCubit(_officerService, _youthService),
          ),
          BlocProvider(create: (_) => ActivityListCubit(_activityService)),
        ],
        child: MaterialApp.router(
          title: 'Nazoratdagi yoshlar',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            appBarTheme: const AppBarTheme(centerTitle: true),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          ),
          routerConfig: _appRouter.router(),
        ),
      ),
    );
  }
}
