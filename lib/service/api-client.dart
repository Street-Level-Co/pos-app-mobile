import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_mobile/config/api-config.dart';
import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/service/auth-service.dart';
import 'package:pos_mobile/service/token-storage.dart';

/// Authenticated HTTP client for every non-auth backend call.
///
/// Attaches the stored JWT as a Bearer token, proactively refreshes it
/// before it expires, and transparently retries a request once if it still
/// comes back 401 (e.g. the server rejected the token for another reason).
/// If refreshing fails, the local session is cleared and
/// [UnauthenticatedException] is thrown so the UI can route to the login
/// screen.
class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final http.Client _client = http.Client();
  final TokenStorage _tokenStorage = TokenStorage();
  final AuthService _authService = AuthService();

  // Ensures concurrent requests share a single in-flight refresh instead of
  // each racing to refresh the (single-use) refresh token.
  Future<void>? _refreshInFlight;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, {Object? body}) async {
    await _ensureFreshToken();

    var response = await _doRequest(method, path, body);

    if (response.statusCode == 401) {
      await _ensureFreshToken(force: true);
      response = await _doRequest(method, path, body);
    }

    return _unwrap(response);
  }

  Future<http.Response> _doRequest(
    String method,
    String path,
    Object? body,
  ) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final accessToken = await _tokenStorage.getAccessToken();
    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _client.put(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: encodedBody);
      default:
        throw ArgumentError('Unsupported method: $method');
    }
  }

  Future<void> _ensureFreshToken({bool force = false}) async {
    if (!force && !await _tokenStorage.isAccessTokenExpired()) return;

    if (_refreshInFlight != null) {
      return _refreshInFlight;
    }

    final refreshFuture = _authService.refresh();
    _refreshInFlight = refreshFuture;
    try {
      await refreshFuture;
    } finally {
      _refreshInFlight = null;
    }
  }

  dynamic _unwrap(http.Response response) {
    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded?['data'];
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthenticatedException(
        decoded?['message'] as String? ?? 'Session expired. Please log in again.',
      );
    }

    final message = decoded?['message'] as String? ??
        decoded?['error'] as String? ??
        'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
