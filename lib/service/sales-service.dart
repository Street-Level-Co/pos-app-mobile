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
}
