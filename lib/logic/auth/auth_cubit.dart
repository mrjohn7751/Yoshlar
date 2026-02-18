import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/auth_service.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> checkAuth() async {
    if (!_authService.hasToken) {
      emit(AuthUnauthenticated());
      return;
    }
    try {
      emit(AuthLoading());
      final user = await _authService.me();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authService.login(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(safeErrorMessage(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> updateProfile({
    String? username,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    try {
      final user = await _authService.updateProfile(
        username: username,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(safeErrorMessage(e)));
      // Re-emit authenticated state so user stays logged in
      try {
        final currentUser = await _authService.me();
        emit(AuthAuthenticated(currentUser));
      } catch (_) {
        // If me() also fails, stay in error state
      }
    }
  }

  Future<void> updateProfilePhoto(Uint8List photoBytes) async {
    try {
      final user = await _authService.updateProfilePhoto(photoBytes);
      emit(AuthAuthenticated(user));
    } catch (e) {
      rethrow;
    }
  }

  void forceLogout() {
    emit(AuthUnauthenticated());
  }
}
