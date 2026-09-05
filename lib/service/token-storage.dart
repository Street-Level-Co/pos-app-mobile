import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pos_mobile/model/auth-response.dart';

/// Persists JWT auth/refresh tokens in the platform secure storage
/// (Android Keystore-backed EncryptedSharedPreferences / iOS Keychain)
/// instead of plain SharedPreferences.
class TokenStorage {
  TokenStorage._internal();
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _expiryKey = 'auth_access_token_expiry';
  static const _userIdKey = 'auth_user_id';
  static const _usernameKey = 'auth_username';
  static const _selectedOrgIdKey = 'auth_selected_org_id';
  static const _selectedOrgNameKey = 'auth_selected_org_name';
  static const _organizationsKey = 'auth_organizations';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresInMs,
    required String userId,
  }) async {
    final expiryMillis = DateTime.now().millisecondsSinceEpoch + expiresInMs;
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _expiryKey, value: expiryMillis.toString()),
      _storage.write(key: _userIdKey, value: userId),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> saveUsername(String username) =>
      _storage.write(key: _usernameKey, value: username);

  Future<String?> getUsername() => _storage.read(key: _usernameKey);

  /// Caches the organizations embedded in the login response, so the
  /// organization-switcher in Settings can list them without a separate
  /// (currently unreliable) backend lookup.
  Future<void> saveOrganizations(List<AuthOrganization> organizations) {
    final encoded = jsonEncode(
      organizations.map((o) => {'id': o.id, 'name': o.name}).toList(),
    );
    return _storage.write(key: _organizationsKey, value: encoded);
  }

  Future<List<AuthOrganization>> getOrganizations() async {
    final raw = await _storage.read(key: _organizationsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => AuthOrganization.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Persists the organization the user picked for this session (post-login,
  /// or switched later from Settings).
  Future<void> saveSelectedOrganization({
    required String orgId,
    required String orgName,
  }) async {
    await Future.wait([
      _storage.write(key: _selectedOrgIdKey, value: orgId),
      _storage.write(key: _selectedOrgNameKey, value: orgName),
    ]);
  }

  Future<String?> getSelectedOrgId() => _storage.read(key: _selectedOrgIdKey);

  Future<String?> getSelectedOrgName() =>
      _storage.read(key: _selectedOrgNameKey);

  /// True once the access token is expired, or within [skew] of expiring,
  /// so callers can refresh proactively instead of waiting on a 401.
  Future<bool> isAccessTokenExpired({
    Duration skew = const Duration(seconds: 10),
  }) async {
    final raw = await _storage.read(key: _expiryKey);
    if (raw == null) return true;
    final expiryMillis = int.tryParse(raw) ?? 0;
    return DateTime.now().add(skew).millisecondsSinceEpoch >= expiryMillis;
  }

  Future<bool> hasRefreshToken() async => (await getRefreshToken()) != null;

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiryKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _selectedOrgIdKey),
      _storage.delete(key: _selectedOrgNameKey),
      _storage.delete(key: _organizationsKey),
    ]);
  }
}
