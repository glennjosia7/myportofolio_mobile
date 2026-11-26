import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class ApiClient {
  ApiClient({http.Client? client, String baseUrl = apiBaseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = Uri.parse(baseUrl);

  final http.Client _client;
  final Uri _baseUrl;

  void close() => _client.close();

  Future<http.Response> _request(
    String method,
    String path, {
    required int expectedCode,
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, _baseUrl.resolve('/api/v1/$path/'))
      ..followRedirects = false
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Token $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException('Tidak dapat terhubung ke server.');
    }
    if (response.statusCode != expectedCode) {
      final message = switch (response.statusCode) {
        400 => 'Data ditolak oleh server. Periksa isian Anda.',
        401 => 'Sesi tidak valid. Silakan masuk lagi.',
        403 => 'Akun ini tidak memiliki izin untuk tindakan tersebut.',
        _ => 'Permintaan gagal (${response.statusCode}). Coba lagi.',
      };
      throw ApiException(message, statusCode: response.statusCode);
    }
    return response;
  }

  T _decode<T>(http.Response response, T Function(Object? json) parse) {
    try {
      return parse(jsonDecode(utf8.decode(response.bodyBytes)));
    } on FormatException {
      throw const ApiException('Format respons server tidak valid.');
    } on TypeError {
      throw const ApiException('Struktur respons server tidak valid.');
    }
  }

  Future<List<Project>> getProjects() async {
    final response = await _request('GET', 'projects', expectedCode: 200);
    return _decode(
      response,
      (json) => (json as List<dynamic>)
          .map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _request(
      'POST',
      'projects',
      expectedCode: 201,
      token: token,
      body: project.toJson(),
    );
    return _decode(
      response,
      (json) => Project.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<Certification>> getCertifications() async {
    final response = await _request('GET', 'certifications', expectedCode: 200);
    return _decode(
      response,
      (json) => (json as List<dynamic>)
          .map((item) => Certification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Certification> createCertification(
    Certification certification, {
    required String token,
  }) async {
    final response = await _request(
      'POST',
      'certifications',
      expectedCode: 201,
      token: token,
      body: certification.toJson(),
    );
    return _decode(
      response,
      (json) => Certification.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<String> obtainToken(String username, String password) async {
    final http.Response response;
    try {
      response = await _request(
        'POST',
        'auth/token',
        expectedCode: 200,
        body: {'username': username, 'password': password},
      );
    } on ApiException catch (error) {
      if (error.statusCode == 400) {
        throw const ApiException(
          'Username atau password salah.',
          statusCode: 400,
        );
      }
      rethrow;
    }
    return _decode(response, (json) {
      final token = (json as Map<String, dynamic>)['token'] as String?;
      if (token == null || token.isEmpty) throw const FormatException();
      return token;
    });
  }

  Future<void> logout(String token) async {
    await _request('POST', 'auth/logout', expectedCode: 204, token: token);
  }
}
