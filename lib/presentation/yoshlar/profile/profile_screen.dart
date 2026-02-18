import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/logic/auth/auth_cubit.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = 'profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _usernameController.text = authState.user.username ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);

    try {
      String? username;
      String? currentPassword;
      String? newPassword;
      String? newPasswordConfirmation;

      final authState = cubit.state;
      if (authState is AuthAuthenticated) {
        if (_usernameController.text.trim() != (authState.user.username ?? '')) {
          username = _usernameController.text.trim();
        }
      }

      if (_newPasswordController.text.isNotEmpty) {
        currentPassword = _currentPasswordController.text;
        newPassword = _newPasswordController.text;
        newPasswordConfirmation = _confirmPasswordController.text;
      }

      if (username == null && newPassword == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Hech narsa o'zgartirilmadi")),
        );
        setState(() => _isSaving = false);
        return;
      }

      await cubit.updateProfile(
        username: username,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      messenger.showSnackBar(
        const SnackBar(content: Text("Profil muvaffaqiyatli yangilandi!")),
      );
      navigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(content: Text("Xatolik: ${safeErrorMessage(e)}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profil sozlamalari",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPhotoCard(),
                const SizedBox(height: 16),
                _buildCard(
                  title: "Foydalanuvchi nomi",
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: _inputDecoration("Foydalanuvchi nomi"),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Foydalanuvchi nomi bo'sh bo'lishi mumkin emas";
                      }
                      if (val.trim().length < 3) {
                        return "Kamida 3 ta belgi";
                      }
                      if (!RegExp(r'^[a-z0-9.]+$').hasMatch(val.trim())) {
                        return "Faqat kichik harflar, raqamlar va nuqta";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: "Parolni o'zgartirish",
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        decoration: _passwordDecoration(
                          "Joriy parol",
                          _obscureCurrent,
                          () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                        validator: (val) {
                          if (_newPasswordController.text.isNotEmpty &&
                              (val == null || val.isEmpty)) {
                            return "Joriy parolni kiriting";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        decoration: _passwordDecoration(
                          "Yangi parol",
                          _obscureNew,
                          () => setState(() => _obscureNew = !_obscureNew),
                        ),
                        validator: (val) {
                          if (val != null && val.isNotEmpty && val.length < 8) {
                            return "Kamida 8 ta belgi";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        decoration: _passwordDecoration(
                          "Yangi parolni tasdiqlang",
                          _obscureConfirm,
                          () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (val) {
                          if (_newPasswordController.text.isNotEmpty &&
                              val != _newPasswordController.text) {
                            return "Parollar mos kelmadi";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3384C3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Saqlash",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    final authState = context.read<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final photoUrl = user?.displayPhotoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF3)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                  )
                : Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "@${user?.username ?? user?.email ?? ''}",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (!user!.hasDisplayPhoto) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Rasmingiz yuklanmagan",
                    style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  InputDecoration _passwordDecoration(String hint, bool obscure, VoidCallback onToggle) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey.shade500,
          size: 20,
        ),
        onPressed: onToggle,
      ),
    );
  }
}
