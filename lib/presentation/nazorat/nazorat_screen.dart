import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/logic/dashboard/dashboard_cubit.dart';
import 'package:yoshlar/presentation/auth/auth_page.dart';
import 'package:yoshlar/presentation/nazorat/history/password_reset_history.dart';
import 'package:yoshlar/presentation/nazorat/jarayonlar/nazorat_jarayon_screen.dart';
import 'package:yoshlar/presentation/nazorat/main/main.dart';
import 'package:yoshlar/presentation/nazorat/masullar/nazorat_masul_screen.dart';
import 'package:yoshlar/presentation/nazorat/profile/nazorat_profile_screen.dart';
import 'package:yoshlar/presentation/nazorat/yoshlar/nazorat_yoshlar.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = '/nazorat_dashboard';
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<Widget> _pages = [
    const NazoratMainScreen(),
    NazoratYoshlarScreen(),
    const NazoratMasulScreen(),
    const ProcessBody(),
    const PasswordResetHistoryScreen(),
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.goNamed(LoginPage.routeName);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              _currentIndex = 0;
              setState(() {});
            },
            child: Image.asset('assets/images/logo.png', height: 36),
          ),
          const SizedBox(width: 10),
          const Text(
            "Ёшлар назорати",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            context.goNamed(NazoratProfileScreen.routeName);
          },
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state is AuthAuthenticated ? state.user : null;
              final photoUrl = user?.displayPhotoUrl;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Icon(
                          Icons.person,
                          color: Colors.blue.shade700,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 3),
        GestureDetector(
          onTap: () {
            context.read<AuthCubit>().logout();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.logout, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade500,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Бош саҳифа',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Ёшлар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search),
            label: "Масуллар",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Жарайонлар',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Тарих',
          ),
        ],
      ),
    );
  }
}
