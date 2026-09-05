import 'package:pos_mobile/model/item-catalog.dart';
import 'package:pos_mobile/service/api-client.dart';

/// Talks to the Spring Boot `/api/catalog` endpoints — an item's listing
/// (price, image, description) within one organization.
class ItemCatalogService {
  ItemCatalogService._internal();
  static final ItemCatalogService _instance = ItemCatalogService._internal();
  factory ItemCatalogService() => _instance;

  final ApiClient _client = ApiClient();

  Future<ItemCatalog> register(CreateItemCatalog input) async {
    final data = await _client.post('/api/catalog/register', body: input.toJson());
    return ItemCatalog.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ItemCatalog>> getAllForOrganization(String orgId) async {
    final data = await _client.get('/api/catalog/all/$orgId');
    return (data as List)
        .map((e) => ItemCatalog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ItemCatalog> getById(String catalogItemId) async {
    final data = await _client.get('/api/catalog/$catalogItemId');
    return ItemCatalog.fromJson(data as Map<String, dynamic>);
  }

  Future<ItemCatalog> update(String catalogItemId, UpdateItemCatalog input) async {
    final data = await _client.put('/api/catalog/$catalogItemId', body: input.toJson());
    return ItemCatalog.fromJson(data as Map<String, dynamic>);
  }

  Future<int> getCount(String orgId) async {
    final data = await _client.get('/api/catalog/count/$orgId');
    return (data as num).toInt();
  }
}
