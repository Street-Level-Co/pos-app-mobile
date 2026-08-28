class Product {
  final String id;
  final String name;
  final int stock;
  final String sku;
  final double price;
  final String image;
  final String category;
  final String? description;
  final double? cost;
  final bool? trackInventory;
  final bool? isActive;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.sku,
    required this.price,
    required this.image,
    required this.category,
    this.description,
    this.cost,
    this.trackInventory,
    this.isActive,
  });


}