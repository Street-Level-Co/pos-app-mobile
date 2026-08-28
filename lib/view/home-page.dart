import 'package:flutter/material.dart';
import 'package:pos_mobile/model/buying-product.dart';
import 'package:pos_mobile/service/theme-changer.dart';
import 'package:pos_mobile/view/app-drawer.dart';
import 'package:pos_mobile/view/cart-page.dart';
import 'dart:developer';

import '../model/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  int cartItemCount = 0;
  double cartTotal = 0;
  late List<BuyingProduct> cartList = [];

  final List<String> categories = ['All', 'Coffee', 'Pastries', 'Sandwiches'];

  final List<Product> menuItems = [
    Product(
      name: 'Caramel Macchiato',
      price: 4.50,
      image:
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=400',
      category: 'Coffee',
      id: '790123GHJKASDFNBKL',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'Butter Croissant',
      price: 3.00,
      image: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',
      category: 'Pastries',
      id: '120893fhjgASDBM,',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'Turkey Club Sandwich',
      price: 8.50,
      image: 'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=400',
      category: 'Sandwiches',
      id: '0789231gfhjasdvd',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'Double Espresso',
      price: 2.50,
      image:
          'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=400',
      category: 'Coffee',
      id: 'asdhjikl67213r567',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'Blueberry Muffin',
      price: 3.25,
      image: '',
      category: 'Pastries',
      id: '89123hjvdsa',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'Vanilla Latte',
      price: 4.00,
      image: 'https://images.unsplash.com/photo-1561882468-9110e03e0f78?w=400',
      category: 'Coffee',
      id: '123789fhgvujdfsad',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'Iced Americano',
      price: 3.50,
      image:
          'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400',
      category: 'Coffee',
      id: 'y89127369gvbd',
      stock: 100,
      sku: '',
    ),
    Product(
      name: 'House Drip Coffee',
      price: 2.00,
      image:
          'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
      category: 'Coffee',
      id: '78123tyc12v3hj1',
      stock: 100,
      sku: '',
    ),
  ];

  List<Product> get filteredItems {
    if (selectedCategory == 'All') {
      return menuItems;
    }
    return menuItems
        .where((item) => item.category == selectedCategory)
        .toList();
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

          // Category Filter
          Container(
            height: 50,
            margin: EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF3B82F6) : Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  item: filteredItems[index],
                  onAddToCart: () => _addToCart(filteredItems[index]),
                );
              },
            ),
          ),

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
