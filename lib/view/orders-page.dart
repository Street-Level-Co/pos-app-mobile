import 'package:flutter/material.dart';

import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/sale.dart';
import 'package:pos_mobile/service/sales-service.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/sale-detail-page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  static const _pageSize = 10;

  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  List<Sale> _sales = [];
  int _page = 0;
  int _totalPages = 1;
  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _loading) return;
    if (_page + 1 >= _totalPages) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
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
      final result = await SalesService().getAllForOrganization(
        orgId,
        page: 0,
        size: _pageSize,
      );
      setState(() {
        _sales = result.content;
        _page = result.number;
        _totalPages = result.totalPages;
        _totalElements = result.totalElements;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final orgId = await TokenStorage().getSelectedOrgId();
      if (orgId == null || orgId.isEmpty) return;
      final result = await SalesService().getAllForOrganization(
        orgId,
        page: _page + 1,
        size: _pageSize,
      );
      setState(() {
        _sales = [..._sales, ...result.content];
        _page = result.number;
        _totalPages = result.totalPages;
        _totalElements = result.totalElements;
      });
    } on ApiException catch (_) {
      // Best-effort pagination fetch; leave the already-loaded sales as-is.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  List<MapEntry<String, List<Sale>>> get _groupedSales {
    final groups = <MapEntry<String, List<Sale>>>[];
    for (final sale in _sales) {
      final label = _dateGroupLabel(sale.createdAt);
      if (groups.isNotEmpty && groups.last.key == label) {
        groups.last.value.add(sale);
      } else {
        groups.add(MapEntry(label, [sale]));
      }
    }
    return groups;
  }

  static String _dateGroupLabel(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(local.year, local.month, local.day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
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
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_sales.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Colors.grey[600],
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'No sales yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final groups = _groupedSales;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: groups.length + 1,
        itemBuilder: (context, index) {
          if (index == groups.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: _loadingMore
                    ? CircularProgressIndicator(color: Color(0xFF3B82F6))
                    : Text(
                        'Showing ${_sales.length} of $_totalElements sales',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
              ),
            );
          }

          final group = groups[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  group.key,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...group.value.map(
                (sale) => SaleCard(sale: sale, formatTime: _formatTime),
              ),
              SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

// Sale Card Widget
class SaleCard extends StatelessWidget {
  final Sale sale;
  final String Function(DateTime) formatTime;

  const SaleCard({required this.sale, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final isWalkIn = sale.customerMobile == null;
    final itemCount = sale.items.fold<int>(0, (sum, item) => sum + item.qty);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SaleDetailPage(sale: sale)),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isWalkIn ? Color(0xFF4C1D4C) : Color(0xFF3730A3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isWalkIn
                    ? Icon(Icons.storefront, color: Color(0xFFEC4899), size: 28)
                    : Icon(Icons.person, color: Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWalkIn ? 'Walk-in Customer' : '+${sale.customerMobile}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'} • ${formatTime(sale.createdAt)}',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              '\$${sale.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
