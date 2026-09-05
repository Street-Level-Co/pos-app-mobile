import 'package:pos_mobile/model/organization.dart';

/// Mirrors the backend `User` entity (`app_user` table). The backend also
/// serializes a `password` field on this entity; it is intentionally not
/// read here so a password hash never ends up held in app memory/state.
class User {
  final String? id;
  final String username;
  final String? role;
  final bool? enabled;

  User({this.id, required this.username, this.role, this.enabled});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      username: json['username'] as String,
      role: json['role'] as String?,
      enabled: json['enabled'] as bool?,
    );
  }
}

/// Mirrors the backend `UserOrganization` entity, returned by
/// `GET /api/organization/organizations-by-user/{userId}` and
/// `GET /api/organization/users-by-organization/{organizationId}`.
class UserOrganization {
  final User? user;
  final Organization? org;

  UserOrganization({this.user, this.org});

  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    return UserOrganization(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      org: json['org'] == null
          ? null
          : Organization.fromJson(json['org'] as Map<String, dynamic>),
    );
  }
}
