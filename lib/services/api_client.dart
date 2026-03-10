import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../main.dart' show navigatorKey;
import '../utils/token_storage.dart';
import '../utils/api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  Future<bool>? _refreshInFlight;

  Uri _buildUri(String path, {Map<String, String>? queryParams}) {
    final raw = path.trim();
    final normalized = raw.isEmpty
        ? '/'
        : '/${raw.replaceAll(RegExp(r'^/+'), '')}';
    return Uri.parse('${ApiConfig.baseUrl}$normalized')
        .replace(queryParameters: queryParams);
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final rawBody = response.body.trim();
    Map<String, dynamic> body;
    if (rawBody.isEmpty) {
      body = <String, dynamic>{};
    } else {
      try {
        final decoded = jsonDecode(rawBody);
        body = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{'error': rawBody};
      } catch (_) {
        body = <String, dynamic>{'error': rawBody};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        throw ApiException('Token refreshed, retry request', statusCode: 401);
      }
    }

    final fallbackMessage = response.statusCode == 409
        ? 'Email already registered'
        : 'Request failed';
    throw ApiException(
      (body['error'] ?? fallbackMessage).toString(),
      statusCode: response.statusCode,
      data: body,
    );
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    _refreshInFlight = _doRefreshToken();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<bool> _doRefreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    final isPartner = await TokenStorage.isPartner();
    final refreshPath = isPartner ? '/partner/refresh' : '/auth/refresh';

    try {
      final response = await _client.post(
        _buildUri(refreshPath),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        await TokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      debugPrint('ApiClient._tryRefreshToken: $e');
    }

    await TokenStorage.clearAll();
    _redirectToWelcome();
    return false;
  }

  void _redirectToWelcome() {
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamedAndRemoveUntil('/welcome', (_) => false);
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = false,
  }) async {
    final uri = _buildUri(path, queryParams: queryParams);

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client
          .get(uri, headers: await _headers(auth: auth))
          .timeout(ApiConfig.timeout);

      try {
        return await _handleResponse(response);
      } on ApiException catch (e) {
        if (e.statusCode == 401 && attempt == 0) continue;
        rethrow;
      }
    }
    throw ApiException('Request failed after retry');
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = _buildUri(path);

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client
          .post(
            uri,
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      try {
        return await _handleResponse(response);
      } on ApiException catch (e) {
        if (e.statusCode == 401 && attempt == 0) continue;
        rethrow;
      }
    }
    throw ApiException('Request failed after retry');
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = _buildUri(path);

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client
          .put(
            uri,
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      try {
        return await _handleResponse(response);
      } on ApiException catch (e) {
        if (e.statusCode == 401 && attempt == 0) continue;
        rethrow;
      }
    }
    throw ApiException('Request failed after retry');
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = _buildUri(path);

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client
          .patch(
            uri,
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      try {
        return await _handleResponse(response);
      } on ApiException catch (e) {
        if (e.statusCode == 401 && attempt == 0) continue;
        rethrow;
      }
    }
    throw ApiException('Request failed after retry');
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    final uri = _buildUri(path);

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client
          .delete(uri, headers: await _headers(auth: auth))
          .timeout(ApiConfig.timeout);

      try {
        return await _handleResponse(response);
      } on ApiException catch (e) {
        if (e.statusCode == 401 && attempt == 0) continue;
        rethrow;
      }
    }
    throw ApiException('Request failed after retry');
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    final uri = _buildUri(path);

    for (int attempt = 0; attempt < 2; attempt++) {
      final request = http.MultipartRequest('POST', uri);

      final token = await TokenStorage.getAccessToken();
      if (auth && token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      try {
        return await _handleResponse(response);
      } on ApiException catch (e) {
        if (e.statusCode == 401 && attempt == 0) continue;
        rethrow;
      }
    }

    throw ApiException('Request failed after retry');
  }
}
