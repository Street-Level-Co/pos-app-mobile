import 'package:pos_mobile/model/country.dart';
import 'package:pos_mobile/service/api-client.dart';

/// Talks to the Spring Boot `/api/country` endpoints.
class CountryService {
  CountryService._internal();
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;

  final ApiClient _client = ApiClient();

  Future<List<Country>> getAll() async {
    final data = await _client.get('/api/country');
    return (data as List)
        .map((e) => Country.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Country> getById(String countryId) async {
    final data = await _client.get('/api/country/$countryId');
    return Country.fromJson(data as Map<String, dynamic>);
  }
}
