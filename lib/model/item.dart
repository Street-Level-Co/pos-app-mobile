/// Mirrors the backend `Item` entity (`item` table: `item_id`, `item_name`).
class Item {
  final String? id;
  final String itemName;

  Item({this.id, required this.itemName});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String?,
      itemName: json['itemName'] as String,
    );
  }
}
