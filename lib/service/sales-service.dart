import 'package:pos_mobile/model/page.dart';
import 'package:pos_mobile/model/sale.dart';
import 'package:pos_mobile/service/api-client.dart';

/// Talks to the Spring Boot `/api/sales` endpoints.
class SalesService {
  SalesService._internal();
  static final SalesService _instance = SalesService._internal();
  factory SalesService() => _instance;

  final ApiClient _client = ApiClient();

  Future<Sale> register(CreateSale input) async {
    final data = await _client.post('/api/sales/register', body: input.toJson());
    return Sale.fromJson(data as Map<String, dynamic>);
  }

  /// Sales for [orgId], newest first, paginated.
  Future<Page<Sale>> getAllForOrganization(
    String orgId, {
    int page = 0,
    int size = 10,
  }) async {
    final query = Uri(queryParameters: {
      'page': page.toString(),
      'size': size.toString(),
    }).query;

    final data = await _client.get('/api/sales/all/$orgId?$query');
    return Page.fromJson(
      data as Map<String, dynamic>,
      (json) => Sale.fromJson(json),
    );
  }

  Future<int> getCount(String orgId) async {
    final data = await _client.get('/api/sales/count/$orgId');
    return (data as num).toInt();
  }
}
