import 'package:easy_search_bar_2/easy_search_bar_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/data/service/youth_service.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/logic/officer/officer_cubit.dart';
import 'package:yoshlar/logic/officer/officer_state.dart';
import 'package:yoshlar/presentation/auth/auth_page.dart';
import 'package:yoshlar/presentation/yoshlar/main/main_item_screen.dart/history_screen.dart';
import 'package:yoshlar/presentation/yoshlar/main/widgets/main_widget.dart';
import 'package:yoshlar/presentation/yoshlar/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = 'main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _youthsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tryLoadYouths();
  }

  void _tryLoadYouths() {
    if (_youthsLoaded) return;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _youthsLoaded = true;
      context.read<OfficerCubit>().loadMyYouths(authState.user.id);
    }
  }

  void _reloadYouths() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<OfficerCubit>().loadMyYouths(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.goNamed(LoginPage.routeName);
        } else if (state is AuthAuthenticated) {
          _tryLoadYouths();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: EasySearchBar2(
          title: const Text(
            'Nazoratdagi yoshlar',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          onSearch: (value) {},
          onSuggestionTap: (data) {},
          searchBackgroundColor: Colors.white,
          searchCursorColor: Colors.blue,
          searchHintText: "Ism bo'yicha qidiruv...",
          actions: [
            GestureDetector(
              onTap: () => context.pushNamed(ProfileScreen.routeName),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.settings, size: 18, color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => context.read<AuthCubit>().logout(),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.logout, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<OfficerCubit, OfficerState>(
          builder: (context, officerState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "Bosh sahifa",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Ma'sul shaxs haqida ma'lumot",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildOfficerInfoCard(authState),
                    const SizedBox(height: 8),
                    const Text(
                      "Yoshlar ro'yxati",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (officerState is OfficerLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (officerState is OfficerYouthsLoaded)
                      ...officerState.youths.map(
                        (user) => GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              HistoryPage.routeName,
                              extra: {'youthId': user.id, 'youthName': user.name},
                            );
                          },
                          child: UserCardWidget(
                            user: user,
                            youthService: context.read<YouthService>(),
                            onPhotoUpdated: () => _reloadYouths(),
                          ),
                        ),
                      )
                    else if (officerState is OfficerError)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(child: Text(officerState.message)),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOfficerInfoCard(AuthState authState) {
    final name = authState is AuthAuthenticated ? authState.user.name : "...";
    final email = authState is AuthAuthenticated
        ? "@${authState.user.username ?? authState.user.email}"
        : "";
    final photoUrl = authState is AuthAuthenticated
        ? authState.user.officerPhotoUrl
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF3)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultOfficerAvatar(),
                  )
                : _defaultOfficerAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultOfficerAvatar() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.blue),
    );
  }
}
