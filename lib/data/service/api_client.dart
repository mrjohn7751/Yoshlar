import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Android emulator: 10.0.2.2, Chrome/Linux: localhost
  static const String baseUrl = 'http://localhost:8000/api';
  static const String storageUrl = 'http://localhost:8000/storage';

  final FlutterSecureStorage _storage;
  void Function()? onUnauthorized;
  String? _token;

  ApiClient(this._storage);

  Future<void> init() async {
    _token = await _storage.read(key: 'auth_token');
  }

  String? get token => _token;

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _token = token;
  }

  Future<void> removeToken() async {
    await _storage.delete(key: 'auth_token');
    _token = null;
  }

  bool get hasToken => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static const Duration _timeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    ).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> multipartPost(
    String path, {
    Map<String, String>? fields,
    Map<String, File>? files,
    List<File>? fileList,
    String fileFieldName = 'images[]',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }
    }

    if (fileList != null) {
      for (final file in fileList) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, file.path),
        );
      }
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> multipartPostWithBytes(
    String path, {
    Map<String, String>? fields,
    Map<String, Uint8List>? fileBytes,
    String fileFieldName = 'photo',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (fileBytes != null) {
      for (final entry in fileBytes.entries) {
        request.files.add(
          http.MultipartFile.fromBytes(
            entry.key,
            entry.value,
            filename: '${entry.key}.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
    }

    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> multipartPostWithBytesList(
    String path, {
    required List<Uint8List> bytesList,
    String fileFieldName = 'images[]',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    for (int i = 0; i < bytesList.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fileFieldName,
          bytesList[i],
          filename: 'image_$i.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      removeToken();
      onUnauthorized?.call();
    }

    final message = body['message'] ?? 'Xatolik yuz berdi';
    throw ApiException(message.toString(), response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

/// Extracts a user-safe error message from any exception.
String safeErrorMessage(Object e) {
  if (e is ApiException) return e.message;
  if (e is TimeoutException) return "So'rov vaqti tugadi. Qaytadan urinib ko'ring.";
  return "Xatolik yuz berdi. Qaytadan urinib ko'ring.";
}
