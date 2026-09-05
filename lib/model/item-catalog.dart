/// Mirrors the backend `CatalogItemSummary` transfer object — the flattened
/// projection returned by `/api/catalog/*` (an item's listing: price, image,
/// description within one organization).
class ItemCatalog {
  final String? id;
  final String itemId;
  final String itemName;
  final String orgId;
  final double price;
  final double? discountedPrice;
  final String? imgUrl;
  final String? description;

  ItemCatalog({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.orgId,
    required this.price,
    this.discountedPrice,
    this.imgUrl,
    this.description,
  });

  factory ItemCatalog.fromJson(Map<String, dynamic> json) {
    return ItemCatalog(
      id: json['id'] as String?,
      itemId: json['itemID'] as String,
      itemName: json['itemName'] as String,
      orgId: json['orgID'] as String,
      price: (json['price'] as num).toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      imgUrl: json['imgUrl'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// Request body for `POST /api/catalog/register`.
///
/// Provide either [itemId] (to reuse an existing item) or [itemName] (the
/// backend will look it up by name, or create a new item with that name).
class CreateItemCatalog {
  final String? itemId;
  final String? itemName;
  final String orgId;
  final double price;
  final double? disPrice;
  final String? imgUrl;
  final String? description;

  CreateItemCatalog({
    this.itemId,
    this.itemName,
    required this.orgId,
    required this.price,
    this.disPrice,
    this.imgUrl,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (itemId != null) 'itemID': itemId,
      if (itemName != null) 'itemName': itemName,
      'orgID': orgId,
      'price': price,
      if (disPrice != null) 'disPrice': disPrice,
      if (imgUrl != null) 'imgUrl': imgUrl,
      if (description != null) 'description': description,
    };
  }
}

/// Request body for `PUT /api/catalog/{catalogItemID}`. Any field left null
/// is left unchanged by the backend.
class UpdateItemCatalog {
  final double? price;
  final double? disPrice;
  final String? imgUrl;
  final String? description;

  UpdateItemCatalog({
    this.price,
    this.disPrice,
    this.imgUrl,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      if (price != null) 'price': price,
      if (disPrice != null) 'disPrice': disPrice,
      if (imgUrl != null) 'imgUrl': imgUrl,
      if (description != null) 'description': description,
    };
  }
}
