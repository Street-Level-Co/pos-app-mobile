import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Completed', 'Refunded', 'Pending'];

  final List<OrderGroup> orderGroups = [
    OrderGroup(
      date: 'TODAY',
      total: 1245.50,
      orders: [
        Order(
          customerName: 'Alice Smith',
          orderId: '#ORD-4921',
          time: '14:30 PM',
          amount: 124.50,
          status: OrderStatus.paid,
          hasAvatar: true,
          avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
        ),
        Order(
          customerName: 'Michael Johnson',
          orderId: '#ORD-4920',
          time: '13:15 PM',
          amount: 45.00,
          status: OrderStatus.pending,
          hasAvatar: false,
          initials: 'MJ',
        ),
        Order(
          customerName: 'David Chen',
          orderId: '#ORD-4919',
          time: '11:45 AM',
          amount: 89.99,
          status: OrderStatus.refunded,
          hasAvatar: true,
          avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
        ),
      ],
    ),
    OrderGroup(
      date: 'YESTERDAY',
      total: 3890.00,
      orders: [
        Order(
          customerName: 'Walk-in Customer',
          orderId: '#ORD-4918',
          time: '18:20 PM',
          amount: 12.50,
          status: OrderStatus.paid,
          hasAvatar: false,
          isWalkIn: true,
        ),
        Order(
          customerName: 'Sarah Wilson',
          orderId: '#ORD-4917',
          time: '16:45 PM',
          amount: 230.00,
          status: OrderStatus.paid,
          hasAvatar: true,
          avatarUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
        ),
      ],
    ),
  ];

  List<OrderGroup> get filteredOrderGroups {
    if (selectedFilter == 'All') {
      return orderGroups;
    }

    return orderGroups.map((group) {
      final filteredOrders = group.orders.where((order) {
        switch (selectedFilter) {
          case 'Completed':
            return order.status == OrderStatus.paid;
          case 'Refunded':
            return order.status == OrderStatus.refunded;
          case 'Pending':
            return order.status == OrderStatus.pending;
          default:
            return true;
        }
      }).toList();

      return OrderGroup(
        date: group.date,
        total: filteredOrders.fold(0, (sum, order) => sum + order.amount),
        orders: filteredOrders,
      );
    }).where((group) => group.orders.isNotEmpty).toList();
  }

  int get totalOrders {
    return orderGroups.fold(0, (sum, group) => sum + group.orders.length);
  }

  int get displayedOrders {
    return filteredOrderGroups.fold(0, (sum, group) => sum + group.orders.length);
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
          'Order History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              // Open date picker
            },
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
                  hintText: 'Search ID, name or amount...',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                  suffixIcon: Icon(Icons.tune, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Filter Tabs
          Container(
            height: 50,
            margin: EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
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
                        filter,
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

          // Orders List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredOrderGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = filteredOrderGroups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            group.date,
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '\$${group.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Orders in this group
                    ...group.orders.map((order) => OrderCard(order: order)).toList(),

                    SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Showing $displayedOrders of $totalOrders orders',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to order details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${order.orderId} details')),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: order.isWalkIn 
                    ? Color(0xFF4C1D4C)
                    : order.hasAvatar
                        ? Colors.transparent
                        : Color(0xFF3730A3),
                shape: BoxShape.circle,
              ),
              child: order.hasAvatar
                  ? ClipOval(
                      child: Image.network(
                        order.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: order.isWalkIn
                          ? Icon(Icons.storefront, color: Color(0xFFEC4899), size: 28)
                          : Text(
                              order.initials ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
            ),
            SizedBox(width: 16),

            // Order Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        order.orderId,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        order.time,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.status == OrderStatus.refunded
                      ? '\$${order.amount.toStringAsFixed(2)}'
                      : '\$${order.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: order.status == OrderStatus.refunded
                        ? Color(0xFF6B7280)
                        : Color(0xFF3B82F6),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: order.status == OrderStatus.refunded
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        _getStatusText(order.status),
                        style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
        return Color(0xFF10B981);
      case OrderStatus.pending:
        return Color(0xFFF59E0B);
      case OrderStatus.refunded:
        return Color(0xFFEF4444);
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }
}

// Models
enum OrderStatus { paid, pending, refunded }

class Order {
  final String customerName;
  final String orderId;
  final String time;
  final double amount;
  final OrderStatus status;
  final bool hasAvatar;
  final String? avatarUrl;
  final String? initials;
  final bool isWalkIn;

  Order({
    required this.customerName,
    required this.orderId,
    required this.time,
    required this.amount,
    required this.status,
    this.hasAvatar = false,
    this.avatarUrl,
    this.initials,
    this.isWalkIn = false,
  });
}

class OrderGroup {
  final String date;
  final double total;
  final List<Order> orders;

  OrderGroup({
    required this.date,
    required this.total,
    required this.orders,
  });
}