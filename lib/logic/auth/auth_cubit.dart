import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoshlar/data/service/api_client.dart';
import 'package:yoshlar/data/service/auth_service.dart';
import 'package:yoshlar/data/service/cache_service.dart';
import 'package:yoshlar/logic/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final CacheService _cacheService;

  AuthCubit(this._authService, this._cacheService) : super(AuthInitial());

  Future<void> checkAuth() async {
    if (!_authService.hasToken) {
      emit(AuthUnauthenticated());
      return;
    }
    try {
      emit(AuthLoading());

      // 1. Avval keshdan user o'qish - tez splash
      final cachedUser = await _cacheService.getCachedAuthUser();
      if (cachedUser != null) {
        emit(AuthAuthenticated(cachedUser));
      }

      // 2. API dan tekshirish va yangilash
      final user = await _authService.me();
      await _cacheService.cacheAuthUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      // API xato bo'lsa, keshdan davom etish (offline grace period)
      final cachedUser = await _cacheService.getCachedAuthUser();
      if (cachedUser != null) {
        emit(AuthAuthenticated(cachedUser));
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authService.login(email, password);
      await _cacheService.cacheAuthUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(safeErrorMessage(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      await _cacheService.clearAll();
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
      await _cacheService.cacheAuthUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(safeErrorMessage(e)));
      // Re-emit authenticated state so user stays logged in
      try {
        final currentUser = await _authService.me();
        await _cacheService.cacheAuthUser(currentUser);
        emit(AuthAuthenticated(currentUser));
      } catch (_) {
        // If me() also fails, stay in error state
      }
    }
  }

  Future<void> updateProfilePhoto(Uint8List photoBytes) async {
    try {
      final user = await _authService.updateProfilePhoto(photoBytes);
      await _cacheService.cacheAuthUser(user);
      emit(AuthAuthenticated(user));
    } catch (e) {
      rethrow;
    }
  }

  void forceLogout() {
    _cacheService.clearAll();
    emit(AuthUnauthenticated());
  }
}
