import 'dart:typed_data';

import 'package:yoshlar/data/model/auth_user.dart';
import 'package:yoshlar/data/service/api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<AuthUser> login(String email, String password) async {
    final response = await _client.post('/auth/login', body: {
      'login': email,
      'password': password,
    });
    final token = response['token'];
    if (token == null) {
      throw ApiException("Server javobida token topilmadi", 0);
    }
    await _client.saveToken(token.toString());
    final userData = response['user'];
    if (userData == null) {
      throw ApiException("Server javobida foydalanuvchi topilmadi", 0);
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(userData));
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _client.removeToken();
    }
  }

  Future<AuthUser> me() async {
    final response = await _client.get('/auth/me');
    final userData = response['user'];
    if (userData == null) {
      throw ApiException("Foydalanuvchi ma'lumoti topilmadi", 0);
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(userData));
  }

  Future<AuthUser> updateProfile({
    String? username,
    String? currentPassword,
    String? newPassword,
    String? newPasswordConfirmation,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (currentPassword != null) body['current_password'] = currentPassword;
    if (newPassword != null) {
      body['new_password'] = newPassword;
      body['new_password_confirmation'] = newPasswordConfirmation;
    }
    final response = await _client.put('/auth/profile', body: body);
    final userData = response['user'];
    if (userData == null) {
      throw ApiException("Profil ma'lumoti topilmadi", 0);
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(userData));
  }

  Future<AuthUser> updateProfilePhoto(Uint8List photoBytes) async {
    final response = await _client.multipartPostWithBytes(
      '/auth/profile/photo',
      fileBytes: {'photo': photoBytes},
      fileFieldName: 'photo',
    );
    final userData = response['user'];
    if (userData == null) {
      throw ApiException("Profil ma'lumoti topilmadi", 0);
    }
    return AuthUser.fromJson(Map<String, dynamic>.from(userData));
  }

  Future<Map<String, dynamic>> faceReset({
    required String username,
    required Uint8List selfieBytes,
  }) async {
    return await _client.multipartPostWithBytes(
      '/auth/face-reset',
      fields: {'username': username},
      fileBytes: {'selfie': selfieBytes},
      fileFieldName: 'selfie',
    );
  }

  Future<Map<String, dynamic>> getResetLogs({int page = 1}) async {
    return await _client.get('/password-reset-logs?page=$page');
  }

  bool get hasToken => _client.hasToken;
}
