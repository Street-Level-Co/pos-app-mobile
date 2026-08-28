import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresInMs,
  }) async {
    final expiryMillis = DateTime.now().millisecondsSinceEpoch + expiresInMs;
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _expiryKey, value: expiryMillis.toString()),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

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
    ]);
  }
}
