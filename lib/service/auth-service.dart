import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_mobile/config/api-config.dart';
import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/auth-response.dart';
import 'package:pos_mobile/service/token-storage.dart';

/// Talks to the Spring Boot `/api/auth/*` endpoints and persists the
/// resulting JWT/refresh token pair via [TokenStorage].
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final http.Client _client = http.Client();
  final TokenStorage _tokenStorage = TokenStorage();

  /// Logs in and returns the organizations embedded in the response, so
  /// callers can drive organization selection without a separate lookup.
  Future<List<AuthOrganization>> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final auth = AuthResponse.fromJson(
      _unwrap(response) as Map<String, dynamic>,
    );
    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      expiresInMs: auth.expiresInMs,
      userId: auth.userId,
    );
    await _tokenStorage.saveUsername(username);
    await _tokenStorage.saveOrganizations(auth.organizations);
    return auth.organizations;
  }

  Future<void> register(String username, String password) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    _unwrap(response);
  }

  /// Exchanges the stored refresh token for a new token pair.
  ///
  /// Throws [UnauthenticatedException] if there is no refresh token, or the
  /// backend rejects it (expired/revoked) — the local session is cleared in
  /// that case so the caller can route to the login screen.
  Future<void> refresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      throw UnauthenticatedException();
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      await _tokenStorage.clear();
      throw UnauthenticatedException();
    }

    final auth = AuthResponse.fromJson(
      _unwrap(response) as Map<String, dynamic>,
    );
    await _tokenStorage.saveTokens(
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
      expiresInMs: auth.expiresInMs,
      userId: auth.userId,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (_) {
        // Best-effort server-side revocation; local session is cleared
        // below regardless so the device always ends up logged out.
      }
    }
    await _tokenStorage.clear();
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasRefreshToken();

  /// The signed-in user's id, if known.
  ///
  /// Sessions established before `userId` started being persisted locally
  /// won't have it stored yet; in that case this forces one refresh (which
  /// now also returns `userId`) to backfill it, instead of reporting the
  /// user as signed out when they aren't.
  Future<String?> currentUserId() async {
    final userId = await _tokenStorage.getUserId();
    if (userId != null) return userId;
    if (!await _tokenStorage.hasRefreshToken()) return null;

    try {
      await refresh();
    } catch (_) {
      // Best-effort backfill; if it fails for any reason (offline, refresh
      // token rejected, ...) just report the user id as unknown.
      return null;
    }
    return _tokenStorage.getUserId();
  }

  Future<String?> currentUsername() => _tokenStorage.getUsername();

  dynamic _unwrap(http.Response response) {
    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        body = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body?['data'];
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw UnauthenticatedException(
        body?['message'] as String? ?? 'Invalid username or password',
      );
    }

    final message = body?['message'] as String? ??
        body?['error'] as String? ??
        'Request failed (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
