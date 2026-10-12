import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final StorageService storage;
  final http.Client _client = http.Client();
  bool _isRefreshing = false;

  ApiClient({required this.storage});

  String get baseUrl {
    final customUrl = storage.getBaseUrl();
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.endsWith('/') ? customUrl : '$customUrl/';
    }
    return ApiConstants.defaultBaseUrl;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final fullUrl = '$baseUrl$normalizedPath';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  Map<String, String> _headers({bool requiresAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path, queryParams);
      final response = await _client.get(uri, headers: _headers(requiresAuth: requiresAuth));
      return _processResponse(response);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> post(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final response = await _client.post(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> put(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final response = await _client.put(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> patch(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final response = await _client.patch(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> delete(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final response = await _client.delete(
        uri,
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> _sendWithRetry(Future<dynamic> Function() requestFn, {bool requiresAuth = true}) async {
    try {
      return await requestFn();
    } on ApiException catch (e) {
      if (e.statusCode == 401 && requiresAuth && !_isRefreshing) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return await requestFn();
        }
      }
      rethrow;
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    _isRefreshing = true;
    try {
      final uri = _buildUri(ApiConstants.authTokenRefresh);
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final newAccess = data['access'] as String?;
        final newRefresh = data['refresh'] as String? ?? refreshToken;
        if (newAccess != null) {
          await storage.saveTokens(access: newAccess, refresh: newRefresh);
          return true;
        }
      }
      // If refresh failed with 401 or invalid, clear tokens
      await storage.clearTokens();
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 204) {
      return null;
    }

    dynamic responseBody;
    try {
      responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      responseBody = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }

    String errorMessage = 'Request failed with status ${response.statusCode}';
    if (responseBody is Map) {
      if (responseBody.containsKey('detail')) {
        errorMessage = responseBody['detail'].toString();
      } else if (responseBody.containsKey('message')) {
        errorMessage = responseBody['message'].toString();
      } else {
        errorMessage = responseBody.entries
            .map((e) => '${e.key}: ${e.value}')
            .join('; ');
      }
    } else if (responseBody is List) {
      errorMessage = responseBody.join('; ');
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      data: responseBody,
    );
  }
}
