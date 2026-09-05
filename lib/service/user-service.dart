import 'package:pos_mobile/model/user.dart';
import 'package:pos_mobile/service/api-client.dart';

/// Talks to the Spring Boot backend for the `User` (`app_user`) entity.
///
/// Registration/login/refresh/logout live on `/api/auth` and are handled by
/// [AuthService] already; the backend exposes no other direct `User` CRUD
/// endpoints, so this service covers the one remaining user-centric lookup.
class UserService {
  UserService._internal();
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  final ApiClient _client = ApiClient();

  Future<List<UserOrganization>> getOrganizationsByUser(String userId) async {
    final data = await _client
        .get('/api/organization/organizations-by-user/$userId');
    return (data as List)
        .map((e) => UserOrganization.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
