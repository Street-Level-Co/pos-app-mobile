import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pos_mobile/model/buying-product.dart';
import 'package:pos_mobile/model/sale.dart';
import 'package:pos_mobile/view/checkout-page.dart';
import 'package:pos_mobile/view/home-page.dart';

class CartPage extends StatefulWidget {

  final List<BuyingProduct> productList;
  const CartPage({super.key, required this.productList});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final double taxRate = 0.08; // 8% tax
  late List<CartItem> cartItems = [];
  final _customerMobileController = TextEditingController();
  DiscountType? _discountType;
  double? _discountValue;

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get discountAmount {
    if (_discountType == null || _discountValue == null) return 0;
    final amount = _discountType == DiscountType.percentage
        ? subtotal * (_discountValue! / 100)
        : _discountValue!;
    return amount.clamp(0, subtotal);
  }

  double get tax {
    return (subtotal - discountAmount) * taxRate;
  }

  double get total {
    return subtotal - discountAmount + tax;
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      cartItems[index].quantity += change;
      if (cartItems[index].quantity < 1) {
        cartItems[index].quantity = 1;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  void dispose() {
    _customerMobileController.dispose();
    super.dispose();
  }

  Future<void> _openDiscountDialog() async {
    var selectedType = _discountType ?? DiscountType.percentage;
    final valueController = TextEditingController(
      text: _discountValue == null ? '' : _discountValue.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color(0xFF161B22),
          title: Text('Add Discount', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DiscountTypeChip(
                      label: 'Percentage (%)',
                      isSelected: selectedType == DiscountType.percentage,
                      onTap: () => setDialogState(() => selectedType = DiscountType.percentage),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _DiscountTypeChip(
                      label: 'Amount (\$)',
                      isSelected: selectedType == DiscountType.amount,
                      onTap: () => setDialogState(() => selectedType = DiscountType.amount),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: valueController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: selectedType == DiscountType.percentage ? 'e.g., 10' : 'e.g., 5.00',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Color(0xFF0D1117),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (_discountType != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _discountType = null;
                    _discountValue = null;
                  });
                  Navigator.pop(context);
                },
                child: Text('Remove Discount', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(valueController.text.trim());
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Enter a valid discount value'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }
                if (selectedType == DiscountType.percentage && value > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Percentage discount can\'t exceed 100%'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                  return;
                }
                setState(() {
                  _discountType = selectedType;
                  _discountValue = value;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _goToCheckout() {
    final mobileText = _customerMobileController.text.trim();
    int? customerMobile;
    if (mobileText.isNotEmpty) {
      customerMobile = int.tryParse(mobileText);
      if (customerMobile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enter a valid mobile number'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          totalAmount: total,
          items: cartItems,
          customerMobile: customerMobile,
          discountType: _discountType,
          discountValue: _discountValue,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    for (var item in widget.productList) {
      log('found item : ${item.product.name} : ${item.qty}');
      cartItems.add(CartItem(
        catalogItemId: item.product.id,
        name: item.product.name,
        price: item.product.price,
        quantity: item.qty,
        image: item.product.image,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D1117),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Sale',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                cartItems = [];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              });
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Mobile Number (Optional)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _customerMobileController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Customer mobile number (optional)',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.phone, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Cart Items List
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey[700],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Color(0xFF21262D),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemWidget(
                        item: item,
                        onIncrease: () => _updateQuantity(index, 1),
                        onDecrease: () => _updateQuantity(index, -1),
                        onRemove: () => _removeItem(index),
                      );
                    },
                  ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  icon: Icons.local_offer_outlined,
                  label: 'Discount',
                  color: Color(0xFF3B82F6),
                  onTap: _openDiscountDialog,
                ),
                ActionButton(
                  icon: Icons.edit_note,
                  label: 'Note',
                  color: Color(0xFF6B7280),
                  onTap: () {
                    // Handle note
                  },
                ),
                ActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan',
                  color: Color(0xFF6B7280),
                  onTap: () {
                    // Handle scan
                  },
                ),
              ],
            ),
          ),

          // Summary Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF161B22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (_discountType != null && _discountValue != null) ...[
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _discountType == DiscountType.percentage
                            ? 'Discount (${_discountValue!.toStringAsFixed(0)}%)'
                            : 'Discount',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '-\$${discountAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax (${(taxRate * 100).toStringAsFixed(0)}%)',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '\$${tax.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFF21262D), height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Charge Button
          Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                onTap: cartItems.isEmpty ? null : _goToCheckout,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Charge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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

// Cart Item Widget
class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemWidget({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.name),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Color(0xFFEF4444),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF161B22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.image, color: Colors.grey[700]),
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
                    item.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}/unit',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white, size: 20),
                    onPressed: onDecrease,
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white, size: 20),
                      onPressed: onIncrease,
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Action Button Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Color(0xFF161B22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Discount Type Chip (used in the Add Discount dialog)
class _DiscountTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiscountTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Cart Item Model
class CartItem {
  final String catalogItemId;
  final String name;
  final double price;
  int quantity;
  final String image;

  CartItem({
    required this.catalogItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
}