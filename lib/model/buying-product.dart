import 'package:pos_mobile/model/product.dart';

class BuyingProduct {
  final Product product;
  int qty;

  BuyingProduct({
    required this.product,
    required this.qty,
  });
}