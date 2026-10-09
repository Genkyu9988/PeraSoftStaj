import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendException implements Exception {
  const BackendException(this.message, {this.status});
  final String message;
  final int? status;
}

class ApiResponse {
  const ApiResponse(this.data, this.etag);
  final Map<String, dynamic> data;
  final String? etag;
}

/// Local-development bearer credential, not a production user login.
class ModyApiClient {
  ModyApiClient({
    required this.baseUrl,
    required this.token,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();
  final String baseUrl;
  final String token;
  final Duration timeout;
  final http.Client _client;

  Future<ApiResponse> request(
    String method,
    String resource, {
    Map<String, Object?>? body,
    String? etag,
  }) async {
    if (token.isEmpty) {
      throw const BackendException(
        'Backend ayarı eksik. backend/flutter.local.json ile çalıştırın.',
      );
    }
    final base = Uri.tryParse(baseUrl);
    if (base == null ||
        !['http', 'https'].contains(base.scheme) ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty) {
      throw const BackendException('Geçersiz backend adresi.');
    }
    // Plain HTTP is only supported for local development, not arbitrary hosts.
    if (base.scheme == 'http' &&
        !['10.0.2.2', '127.0.0.1', 'localhost', '::1'].contains(base.host)) {
      throw const BackendException('Uzak backend için HTTPS gereklidir.');
    }
    final uri = base.resolve('/api/v1/$resource');
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      'If-Match': ?etag,
    };
    try {
      final request = http.Request(method, uri)
        ..headers.addAll(headers)
        ..followRedirects = false;
      if (body != null) request.body = jsonEncode(body);
      final response = await (() async {
        final streamed = await _client.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw BackendException(switch (response.statusCode) {
          401 => 'Backend erişim anahtarı geçersiz.',
          409 => 'Geçmiş kaydı çakışıyor; mevcut kayıt değiştirilmedi.',
          412 =>
            'Seçimler başka bir oturumda değişti. Uygulamayı yeniden açın.',
          _ => 'Backend isteği tamamlanamadı (${response.statusCode}).',
        }, status: response.statusCode);
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid response');
      }
      return ApiResponse(decoded, response.headers['etag']);
    } on BackendException {
      rethrow;
    } on TimeoutException {
      throw const BackendException(
        'Backend yanıt vermedi. Django sunucusunu kontrol edin.',
      );
    } on FormatException {
      throw const BackendException('Backend yanıtı beklenen biçimde değil.');
    } on http.ClientException {
      throw const BackendException(
        'Backend bağlantısı kurulamadı. Django sunucusu açık mı?',
      );
    }
  }

  void close() => _client.close();
}
