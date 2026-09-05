import 'package:pos_mobile/model/organization.dart';
import 'package:pos_mobile/model/user.dart';
import 'package:pos_mobile/service/api-client.dart';

/// Talks to the Spring Boot `/api/organization` endpoints.
class OrganizationService {
  OrganizationService._internal();
  static final OrganizationService _instance = OrganizationService._internal();
  factory OrganizationService() => _instance;

  final ApiClient _client = ApiClient();

  Future<Organization> getById(String organizationId) async {
    final data = await _client.get('/api/organization/$organizationId');
    return Organization.fromJson(data as Map<String, dynamic>);
  }

  Future<Organization> register(CreateOrganization input) async {
    final data =
        await _client.post('/api/organization/register', body: input.toJson());
    return Organization.fromJson(data as Map<String, dynamic>);
  }

  /// Creates an organization and links it directly to [userId].
  Future<Organization> createForUser(
    String userId,
    CreateOrganizationForUser input,
  ) async {
    final data = await _client.post(
      '/api/organization/register-for-user/$userId',
      body: input.toJson(),
    );
    return Organization.fromJson(data as Map<String, dynamic>);
  }

  Future<Organization> update(String organizationId, UpdateOrganization input) async {
    final data = await _client.put(
      '/api/organization/$organizationId',
      body: input.toJson(),
    );
    return Organization.fromJson(data as Map<String, dynamic>);
  }

  /// Links an existing client to an organization.
  Future<ClientOrganization> addUser({
    required String clientId,
    required String orgId,
  }) async {
    final data = await _client.post(
      '/api/organization/add-user',
      body: {'clientID': clientId, 'orgID': orgId},
    );
    return ClientOrganization.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UserOrganization>> getUsersByOrganization(
    String organizationId,
  ) async {
    final data = await _client
        .get('/api/organization/users-by-organization/$organizationId');
    return (data as List)
        .map((e) => UserOrganization.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
