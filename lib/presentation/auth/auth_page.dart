import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';
import 'package:yoshlar/presentation/nazorat/nazorat_screen.dart';
import 'package:yoshlar/presentation/yoshlar/main/main_screen.dart';

import 'widgets/custom_input_widget.dart';
import 'widgets/face_reset_dialog.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login va parolni kiriting")),
      );
      return;
    }
    context.read<AuthCubit>().login(email, password);
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
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo qismi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),

                // Sarlavhalar
                const Text(
                  "Yoshlar nazorati",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tizimga kirish uchun ma'lumotlaringizni kiriting",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Inputlar
                CustomTextField(
                  label: "Foydalanuvchi nomi",
                  hintText: "username",
                  prefixIcon: Icons.person_outline,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Parol",
                  hintText: "******",
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 32),

                // Kirish tugmasi
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Tizimga kirish",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Parolni tiklash
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Parolni unutdingizmi? "),
                    TextButton(
                      onPressed: () => FaceResetDialog.show(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Tiklash",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
