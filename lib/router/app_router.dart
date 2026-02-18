import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/model/officer.dart';
import 'package:yoshlar/data/model/user.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/main.dart';
import 'package:yoshlar/presentation/auth/auth_page.dart';
import 'package:yoshlar/presentation/nazorat/masullar/widgets/add_masul.dart';
import 'package:yoshlar/presentation/nazorat/masullar/widgets/attacht_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/masullar/widgets/masul_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/nazorat_screen.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/add_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/history_into_page.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/import_yoshlar.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar_item/nazorat_yoshlar_history.dart';
import 'package:yoshlar/presentation/splash/splash_page.dart';
import 'package:yoshlar/presentation/yoshlar/main/add_activity/add_activity.dart';
import 'package:yoshlar/presentation/yoshlar/main/main_item_screen.dart/history_screen.dart';
import 'package:yoshlar/presentation/yoshlar/main/main_screen.dart';
import 'package:yoshlar/presentation/nazorat/profile/nazorat_profile_screen.dart';
import 'package:yoshlar/presentation/yoshlar/profile/profile_screen.dart';

class AppRouter {
  final AuthCubit authCubit;

  AppRouter(this.authCubit);

  GoRouter router() => GoRouter(
    debugLogDiagnostics: false,
    navigatorKey: navigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthRefreshNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isOnSplash = state.matchedLocation == '/';
      final isOnLogin = state.matchedLocation == '/login';

      // Splash va login sahifalariga ruxsat
      if (isOnSplash || isOnLogin) return null;

      // Agar auth tekshirilmagan bo'lsa, splash ga yo'naltirish
      if (authState is! AuthAuthenticated) {
        return '/';
      }

      // Role-based route guard
      final user = authState.user;
      final location = state.matchedLocation;

      // Masul rahbariyat sahifalariga kira olmaydi
      if (user.isMasul && location.startsWith('/nazorat_dashboard')) {
        return '/main';
      }

      // Rahbariyat masul sahifalariga kira olmaydi
      if (user.isRahbariyat && location.startsWith('/main')) {
        return '/nazorat_dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        name: LoginPage.routeName,
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        name: SplashPage.routeName,
        path: '/',
        builder: (context, state) => SplashPage(),
      ),
      GoRoute(
        name: DashboardPage.routeName,
        path: '/nazorat_dashboard',
        routes: [
          GoRoute(
            name: NazoratProfileScreen.routeName,
            path: 'profile',
            builder: (context, state) => const NazoratProfileScreen(),
          ),
          GoRoute(
            name: NazoratYoshlarHistory.routeName,
            path: 'nazorat_history',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NazoratYoshlarHistory(
                youthId: extra?['youthId'] as int?,
                youthName: extra?['youthName'] as String?,
              );
            },
          ),
          GoRoute(
            name: AddYouthScreen.routeName,
            path: 'add_youth',
            builder: (context, state) => const AddYouthScreen(),
          ),
          GoRoute(
            name: ImportYouthScreen.routeName,
            path: 'import_youth',
            builder: (context, state) => const ImportYouthScreen(),
          ),
          GoRoute(
            name: AddYouthScreen.editRouteName,
            path: 'edit_youth',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddYouthScreen(
                existingYouth: extra?['youth'] as UserModel?,
              );
            },
          ),
          GoRoute(
            name: AddOfficerScreen.routeName,
            path: 'add_masul',
            builder: (context, state) => const AddOfficerScreen(),
          ),
          GoRoute(
            name: AddOfficerScreen.editRouteName,
            path: 'edit_masul',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddOfficerScreen(
                existingOfficer: extra?['officer'] as OfficerModel?,
              );
            },
          ),
          GoRoute(
            name: AttachYouthScreen.routeName,
            path: 'attacht_yoshlar',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AttachYouthScreen(
                officerId: extra?['officerId'] as int?,
                officerName: extra?['officerName'] as String?,
              );
            },
          ),
          GoRoute(
            name: NazoratHistoryIntoPage.routeName,
            path: 'history_into_page',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NazoratHistoryIntoPage(
                activityId: extra?['activityId'] as int?,
                youthName: extra?['youthName'] as String?,
              );
            },
          ),
          GoRoute(
            name: MasulYoshlarScreen.routeName,
            path: 'masul_yoshlar',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return MasulYoshlarScreen(
                officerId: extra?['officerId'] as int?,
                officerName: extra?['officerName'] as String?,
              );
            },
          ),
        ],
        builder: (context, state) => DashboardPage(),
      ),
      GoRoute(
        name: MainScreen.routeName,
        path: '/main',
        routes: [
          GoRoute(
            name: ProfileScreen.routeName,
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            name: 'masul_edit_youth',
            path: 'edit_youth',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return AddYouthScreen(
                existingYouth: extra?['youth'] as UserModel?,
              );
            },
          ),
          GoRoute(
            name: HistoryPage.routeName,
            path: 'history',
            routes: [
              GoRoute(
                name: AddActivityPage.routeName,
                path: 'add_activity',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return AddActivityPage(
                    youthId: extra?['youthId'] as int?,
                    youthName: extra?['youthName'] as String?,
                  );
                },
              ),
            ],
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return HistoryPage(
                youthId: extra?['youthId'] as int?,
                youthName: extra?['youthName'] as String?,
              );
            },
          ),
        ],
        builder: (context, state) => MainScreen(),
      ),
    ],
  );
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthCubit authCubit) {
    authCubit.stream.listen((_) => notifyListeners());
  }
}
