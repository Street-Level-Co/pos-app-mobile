/// Request body for `POST /api/sales/register`.
class CreateSale {
  final String orgId;
  final int? customerMobile;
  final List<CreateSaleItem> items;

  CreateSale({
    required this.orgId,
    this.customerMobile,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'orgID': orgId,
      if (customerMobile != null) 'customerMobile': customerMobile,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class CreateSaleItem {
  final String catalogItemId;
  final int qty;
  final double price;
  final double? discountPrice;

  CreateSaleItem({
    required this.catalogItemId,
    required this.qty,
    required this.price,
    this.discountPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'catalogItemID': catalogItemId,
      'qty': qty,
      'price': price,
      if (discountPrice != null) 'discountPrice': discountPrice,
    };
  }
}

/// Mirrors the backend `SaleSummary` returned by `/api/sales/register`.
class Sale {
  final String id;
  final String orgId;
  final String? clientId;
  final double totalAmount;
  final DateTime createdAt;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.orgId,
    this.clientId,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      orgId: json['orgID'] as String,
      clientId: json['clientID'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List)
          .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SaleItem {
  final String catalogItemId;
  final String itemName;
  final int qty;
  final double price;
  final double? discountPrice;

  SaleItem({
    required this.catalogItemId,
    required this.itemName,
    required this.qty,
    required this.price,
    this.discountPrice,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      catalogItemId: json['catalogItemID'] as String,
      itemName: json['itemName'] as String,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
    );
  }
}
