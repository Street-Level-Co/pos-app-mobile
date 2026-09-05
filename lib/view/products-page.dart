import 'package:flutter/material.dart';

import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/item-catalog.dart';
import 'package:pos_mobile/service/item-catalog-service.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/new-product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _loading = true;
  String? _error;
  List<ItemCatalog> _catalogItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
        _catalogItems = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openNewItem() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NewProductPage()),
    );
    if (saved == true) _load();
  }

  Future<void> _openEditItem(ItemCatalog catalogItem) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => NewProductPage(catalogItem: catalogItem)),
    );
    if (saved == true) _load();
  }

  List<ItemCatalog> get _filteredItems {
    if (_searchQuery.isEmpty) return _catalogItems;
    final query = _searchQuery.toLowerCase();
    return _catalogItems
        .where((c) => c.itemName.toLowerCase().contains(query))
        .toList();
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
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _openNewItem,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              ElevatedButton(onPressed: _load, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_catalogItems.isEmpty) {
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

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1C2128),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              style: TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search items by name...',
                hintStyle: TextStyle(color: Color(0xFF6B7280)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return CatalogListItem(
                  catalogItem: _filteredItems[index],
                  onEdit: () => _openEditItem(_filteredItems[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Catalog Item Widget
class CatalogListItem extends StatelessWidget {
  final ItemCatalog catalogItem;
  final VoidCallback onEdit;

  const CatalogListItem({required this.catalogItem, required this.onEdit});

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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFF0D1117),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: catalogItem.imgUrl != null && catalogItem.imgUrl!.isNotEmpty
                  ? Image.network(
                      catalogItem.imgUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.image, color: Colors.grey[700], size: 32),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.image, color: Colors.grey[700], size: 32),
                    ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalogItem.itemName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (catalogItem.description != null && catalogItem.description!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    catalogItem.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  '\$${catalogItem.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          GestureDetector(
            onTap: onEdit,
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
