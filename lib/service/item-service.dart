import 'package:pos_mobile/model/item.dart';
import 'package:pos_mobile/model/page.dart';
import 'package:pos_mobile/service/api-client.dart';

/// Talks to the Spring Boot `/api/item` endpoints.
class ItemService {
  ItemService._internal();
  static final ItemService _instance = ItemService._internal();
  factory ItemService() => _instance;

  final ApiClient _client = ApiClient();

  /// Searches items by name (case-insensitive, substring match), paginated.
  Future<Page<Item>> search({
    String keyword = '',
    int page = 0,
    int size = 10,
  }) async {
    final query = Uri(queryParameters: {
      'keyword': keyword,
      'page': page.toString(),
      'size': size.toString(),
    }).query;

    final data = await _client.get('/api/item/all?$query');
    return Page.fromJson(
      data as Map<String, dynamic>,
      (json) => Item.fromJson(json),
    );
  }
}
