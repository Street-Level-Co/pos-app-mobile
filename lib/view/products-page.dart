import 'package:flutter/material.dart';
import 'package:pos_mobile/model/product.dart';
import 'package:pos_mobile/view/new-product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String selectedCategory = 'All';
  int cartItemCount = 3;

  final List<String> categories = ['All', 'Beverages', 'Snacks', 'Pastries'];

  final List<Product> products = [
    Product(
            id: 'Berry Smoothie',

      name: 'Vanilla Latte',
      stock: 45,
      sku: 'VL-001',
      price: 4.50,
      image: 'https://images.unsplash.com/photo-1561882468-9110e03e0f78?w=400',
      category: 'Beverages',
    ),
    Product(
            id: 'Berry Smoothie',

      name: 'Butter Croissant',
      stock: 12,
      sku: 'BC-024',
      price: 3.00,
      image: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',
      category: 'Pastries',
    ),
    Product(
            id: 'Berry Smoothie',

      name: 'Iced Matcha',
      stock: 28,
      sku: 'IM-102',
      price: 5.25,
      image: 'https://images.unsplash.com/photo-1536013284423-e37e9838e98f?w=400',
      category: 'Beverages',
    ),
    Product(
            id: 'Berry Smoothie',

      name: 'Classic Burger',
      stock: 8,
      sku: 'CB-555',
      price: 12.50,
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      category: 'Snacks',
    ),
    Product(
      id: 'Berry Smoothie',
      name: 'Blueberry Muffin',
      stock: 15,
      sku: 'BM-009',
      price: 3.75,
      image: 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400',
      category: 'Pastries',
    ),
    Product(
      id: 'Berry Smoothie',
      name: 'Berry Smoothie',
      stock: 50,
      sku: 'BS-112',
      price: 6.00,
      image: 'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=400',
      category: 'Beverages',
    ),
  ];

  List<Product> get filteredProducts {
    if (selectedCategory == 'All') {
      return products;
    }
    return products.where((product) => product.category == selectedCategory).toList();
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
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1C2128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search items by name or SKU...',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      color: isSelected ? Color(0xFF3B82F6) : Color(0xFF1C2128),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Products List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductListItem(
                  product: filteredProducts[index],
                  onAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewProductPage(product: filteredProducts[index])),
                    );
                  },
                );
              },
            ),
          ),

          // New Product Button
          Container(
            margin: EdgeInsets.all(16),
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Navigate to add new product page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Add New Product'),
                      backgroundColor: Color(0xFF3B82F6),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'New Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

// Product List Item Widget
class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductListItem({
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFF0D1117),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(Icons.image, color: Colors.grey[700], size: 32),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 16),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stock: ${product.stock} • SKU: ${product.sku}',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Add Button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
