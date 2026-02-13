import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:yoshlar/data/service/api_client.dart';

class FaceCompareService {
  final ApiClient _client;

  FaceCompareService(this._client);

  /// Masulning yuzini solishtirish (autentifikatsiyali)
  Future<Map<String, dynamic>> compareFace(int officerId, Uint8List selfieBytes) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/face-compare');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    if (_client.token != null) {
      request.headers['Authorization'] = 'Bearer ${_client.token}';
    }

    request.fields['officer_id'] = officerId.toString();
    request.files.add(
      http.MultipartFile.fromBytes(
        'selfie',
        selfieBytes,
        filename: 'selfie.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      throw Exception('Avtorizatsiya xatosi. Qaytadan kiring.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 403) {
      final isReal = body['is_real'] ?? true;
      if (isReal == false) {
        throw Exception(body['message'] ?? 'Soxta rasm aniqlandi!');
      }
      throw Exception(body['message'] ?? 'Yuz mos kelmadi');
    }

    if (response.statusCode >= 400) {
      throw Exception(body['message'] ?? 'Yuz solishtirish xatosi');
    }

    return body;
  }
}
