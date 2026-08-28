class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInMs;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInMs,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInMs: (json['expiresInMs'] as num?)?.toInt() ?? 0,
    );
  }
}
