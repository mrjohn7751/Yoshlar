import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/presentation/auth/auth_page.dart';
import 'package:yoshlar/presentation/nazorat/nazorat_screen.dart';
import 'package:yoshlar/presentation/yoshlar/main/main_screen.dart';

class SplashPage extends StatefulWidget {
  static const String routeName = '/';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AuthCubit>().checkAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isRahbariyat) {
            context.goNamed(DashboardPage.routeName);
          } else {
            context.goNamed(MainScreen.routeName);
          }
        } else if (state is AuthUnauthenticated) {
          context.goNamed(LoginPage.routeName);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                width: 240,
                height: 240,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
