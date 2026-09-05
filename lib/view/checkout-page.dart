import 'package:flutter/material.dart';
import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/sale.dart';
import 'package:pos_mobile/service/sales-service.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/cart-page.dart';
import 'package:pos_mobile/view/home-page.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<CartItem> items;
  final int? customerMobile;
  final DiscountType? discountType;
  final double? discountValue;

  const CheckoutPage({
    super.key,
    required this.totalAmount,
    required this.items,
    this.customerMobile,
    this.discountType,
    this.discountValue,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPaymentMethod = 'Cash';
  String cashTendered = '';
  bool _isProcessing = false;

  double get cashAmount {
    return double.tryParse(cashTendered) ?? 0.0;
  }

  double get changeDue {
    return cashAmount - widget.totalAmount;
  }

  void _addDigit(String digit) {
    setState(() {
      if (digit == '.') {
        if (!cashTendered.contains('.')) {
          cashTendered += digit;
        }
      } else {
        cashTendered += digit;
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (cashTendered.isNotEmpty) {
        cashTendered = cashTendered.substring(0, cashTendered.length - 1);
      }
    });
  }

  void _setQuickAmount(double amount) {
    setState(() {
      cashTendered = amount.toStringAsFixed(2);
    });
  }

  void _setExactAmount() {
    setState(() {
      cashTendered = widget.totalAmount.toStringAsFixed(2);
    });
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == 'Cash' && cashAmount < widget.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient cash amount'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final orgId = await TokenStorage().getSelectedOrgId();
    if (orgId == null || orgId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No organization selected'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await SalesService().register(
        CreateSale(
          orgId: orgId,
          customerMobile: widget.customerMobile,
          discountType: widget.discountType,
          discountValue: widget.discountValue,
          items: widget.items
              .map((item) => CreateSaleItem(
                    catalogItemId: item.catalogItemId,
                    qty: item.quantity,
                    price: item.price,
                  ))
              .toList(),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF161B22),
        title: Text(
          'Payment Successful',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 60),
            SizedBox(height: 16),
            Text(
              'Amount: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            if (selectedPaymentMethod == 'Cash' && changeDue > 0) ...[
              SizedBox(height: 8),
              Text(
                'Change: \$${changeDue.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close checkout
              Navigator.pop(context); // Close cart
              Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
            ),
            child: Text('Done'),
            
          ),
        ],
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          
          // Total Due
          Text(
            'TOTAL DUE',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$${widget.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 24),

          // Payment Methods
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                PaymentMethodButton(
                  icon: Icons.money,
                  label: 'Cash',
                  isSelected: selectedPaymentMethod == 'Cash',
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Cash';
                    });
                  },
                ),
                SizedBox(width: 12),
                PaymentMethodButton(
                  icon: Icons.credit_card,
                  label: 'Card',
                  isSelected: selectedPaymentMethod == 'Card',
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Card';
                      cashTendered = '';
                    });
                  },
                ),
                SizedBox(width: 12),
                PaymentMethodButton(
                  icon: Icons.smartphone,
                  label: 'Mobile',
                  isSelected: selectedPaymentMethod == 'Mobile',
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Mobile';
                      cashTendered = '';
                    });
                  },
                ),
                SizedBox(width: 12),
                PaymentMethodButton(
                  icon: Icons.more_horiz,
                  label: 'Other',
                  isSelected: selectedPaymentMethod == 'Other',
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'Other';
                      cashTendered = '';
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Cash Input Section (only show for Cash)
          if (selectedPaymentMethod == 'Cash') ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Cash Tendered
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Tendered',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '\$${cashTendered.isEmpty ? '0' : cashTendered}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                cashTendered.contains('.') ? '' : '.00',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 2,
                                height: 30,
                                color: Color(0xFF3B82F6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Change Due
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Due',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\$${changeDue > 0 ? changeDue.toStringAsFixed(2) : '0.00'}',
                          style: TextStyle(
                            color: changeDue > 0 ? Color(0xFF10B981) : Colors.grey[600],
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Quick Amount Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  QuickAmountButton(
                    label: 'Exact',
                    isBlue: true,
                    onTap: _setExactAmount,
                  ),
                  SizedBox(width: 12),
                  QuickAmountButton(
                    label: '\$125',
                    onTap: () => _setQuickAmount(125),
                  ),
                  SizedBox(width: 12),
                  QuickAmountButton(
                    label: '\$130',
                    onTap: () => _setQuickAmount(130),
                  ),
                  SizedBox(width: 12),
                  QuickAmountButton(
                    label: '\$140',
                    onTap: () => _setQuickAmount(140),
                  ),
                  SizedBox(width: 12),
                  QuickAmountButton(
                    label: '\$150',
                    onTap: () => _setQuickAmount(150),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Number Pad
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          NumberButton(number: '1', onTap: () => _addDigit('1')),
                          SizedBox(width: 12),
                          NumberButton(number: '2', onTap: () => _addDigit('2')),
                          SizedBox(width: 12),
                          NumberButton(number: '3', onTap: () => _addDigit('3')),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          NumberButton(number: '4', onTap: () => _addDigit('4')),
                          SizedBox(width: 12),
                          NumberButton(number: '5', onTap: () => _addDigit('5')),
                          SizedBox(width: 12),
                          NumberButton(number: '6', onTap: () => _addDigit('6')),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          NumberButton(number: '7', onTap: () => _addDigit('7')),
                          SizedBox(width: 12),
                          NumberButton(number: '8', onTap: () => _addDigit('8')),
                          SizedBox(width: 12),
                          NumberButton(number: '9', onTap: () => _addDigit('9')),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          NumberButton(number: '.', onTap: () => _addDigit('.')),
                          SizedBox(width: 12),
                          NumberButton(number: '0', onTap: () => _addDigit('0')),
                          SizedBox(width: 12),
                          NumberButton(
                            number: '⌫',
                            onTap: _deleteDigit,
                            icon: Icons.backspace_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selectedPaymentMethod == 'Card' 
                          ? Icons.credit_card 
                          : Icons.smartphone,
                      size: 80,
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Ready to process $selectedPaymentMethod payment',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Charge Button
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
                onTap: _isProcessing ? null : _processPayment,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: _isProcessing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Charge \$${widget.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward, color: Colors.white),
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

// Payment Method Button
class PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : Color(0xFF161B22),
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: Color(0xFF3B82F6), width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Amount Button
class QuickAmountButton extends StatelessWidget {
  final String label;
  final bool isBlue;
  final VoidCallback onTap;

  const QuickAmountButton({
    required this.label,
    this.isBlue = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isBlue ? Colors.transparent : Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isBlue ? Color(0xFF3B82F6) : Colors.white,
            fontSize: 16,
            fontWeight: isBlue ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Number Button
class NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;
  final IconData? icon;

  const NumberButton({
    required this.number,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: Colors.white, size: 28)
                : Text(
                    number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}