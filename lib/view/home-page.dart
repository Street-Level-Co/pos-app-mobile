import 'package:flutter/material.dart';
import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/buying-product.dart';
import 'package:pos_mobile/model/item-catalog.dart';
import 'package:pos_mobile/service/app-counts.dart';
import 'package:pos_mobile/service/item-catalog-service.dart';
import 'package:pos_mobile/service/theme-changer.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/app-drawer.dart';
import 'package:pos_mobile/view/cart-page.dart';
import 'package:pos_mobile/view/new-product.dart';
import 'dart:developer';

import '../model/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int cartItemCount = 0;
  double cartTotal = 0;
  late List<BuyingProduct> cartList = [];

  bool _loading = true;
  String? _error;
  List<Product> menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    AppCounts().refresh();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orgId = await TokenStorage().getSelectedOrgId();
      if (orgId == null || orgId.isEmpty) {
        setState(() {
          _error = 'No organization selected';
          _loading = false;
        });
        return;
      }
      final items = await ItemCatalogService().getAllForOrganization(orgId);
      setState(() {
        menuItems = items.map(_toProduct).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Product _toProduct(ItemCatalog catalogItem) {
    return Product(
      id: catalogItem.id ?? catalogItem.itemId,
      name: catalogItem.itemName,
      stock: 0,
      sku: '',
      price: catalogItem.price,
      image: catalogItem.imgUrl ?? '',
      category: 'All',
      description: catalogItem.description,
    );
  }

  Future<void> _openNewItem() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NewProductPage()),
    );
    if (saved == true) _loadCatalog();
  }

  void _addToCart(Product item) {
    log('Data: ${item.name}', name: 'MyApp');
    setState(() {
      cartItemCount++;
      cartTotal += item.price;
      int index = cartList.indexWhere(
        (savedItem) => savedItem.product.id == item.id,
      );
      if (index != -1) {
        log('item already exist');
        cartList[index].qty += 1;
      } else {
        log('new item added');
        cartList.add(BuyingProduct(product: item, qty: 1));
      }
    });

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D1117),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Catalog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  // Open cart
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Cart clicked')));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(productList: cartList),
                    ),
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$cartItemCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(
              ThemeBuilder.of(context)?.getCurrentBrightness() ==
                      Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              ThemeBuilder.of(context)?.changeTheme();
            },
          ),
        ],
      ),
      drawer: AppDrawer(), // Keep your existing drawer
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or SKU...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  suffixIcon: Icon(
                    Icons.qr_code_scanner,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Catalog
          Expanded(child: _buildCatalogArea()),

          // Cart Footer
          Visibility(
            visible: cartList.isNotEmpty,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Navigate to cart
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(productList: cartList),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: cartList.length > 0
                        ? Row(
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$cartItemCount Items',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'View Cart',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                '\$${cartTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogArea() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 40),
              SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _loadCatalog, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (menuItems.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.grey[600], size: 48),
              SizedBox(height: 16),
              Text(
                'No items in your catalog yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Add Items to Catalog', style: TextStyle(color: Colors.white)),
                onPressed: _openNewItem,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCatalog,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return ProductCard(
            item: menuItems[index],
            onAddToCart: () => _addToCart(menuItems[index]),
          );
        },
      ),
    );
  }
}

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Product item;
  final VoidCallback onAddToCart;

  const ProductCard({required this.item, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF0D1117),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: item.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        item.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[700],
                              size: 40,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        item.name ?? '',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),

          // Product Info
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// // Menu Item Model
// class MenuItem {
//   final String name;
//   final double price;
//   final String image;
//   final String category;
//   final String? placeholder;
//
//   MenuItem({
//     required this.name,
//     required this.price,
//     required this.image,
//     required this.category,
//     this.placeholder,
//   });
// }
