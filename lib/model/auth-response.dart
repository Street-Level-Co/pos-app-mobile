class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInMs;
  final String userId;
  final List<AuthOrganization> organizations;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInMs,
    required this.userId,
    required this.organizations,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInMs: (json['expiresInMs'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as String,
      organizations: (json['organizations'] as List<dynamic>? ?? [])
          .map((e) => AuthOrganization.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// The lightweight `{id, name}` organization summary embedded directly in
/// the `/api/auth/login` response, used to drive the post-login
/// organization-selection screen without a separate lookup call.
class AuthOrganization {
  final String id;
  final String name;

  AuthOrganization({required this.id, required this.name});

  factory AuthOrganization.fromJson(Map<String, dynamic> json) {
    return AuthOrganization(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
