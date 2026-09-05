import 'package:flutter/material.dart';
import 'package:pos_mobile/service/auth-service.dart';
import 'package:pos_mobile/view/business-profile-page.dart';
import 'package:pos_mobile/view/orders-page.dart';
import 'package:pos_mobile/view/products-page.dart';
import 'package:pos_mobile/view/setting-page.dart';
import 'package:pos_mobile/view/sign-in-page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF0D1117),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF8B5CF6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150',
                  ),
                ),
                SizedBox(height: 4),
                FutureBuilder<String?>(
                  future: AuthService().currentUsername(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Jane Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4),
                Text(
                  'Store Manager',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'jane.doe@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 8),
              children: [
                DrawerMenuItem(
                  icon: Icons.home_rounded,
                  iconColor: Color(0xFF3B82F6),
                  title: 'Home',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                DrawerMenuItem(
                  icon: Icons.shopping_bag_rounded,
                  iconColor: Color(0xFF10B981),
                  title: 'Products',
                  badge: '245',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductsPage()),
                    );
                  },
                ),
                DrawerMenuItem(
                  icon: Icons.receipt_long_rounded,
                  iconColor: Color(0xFFF59E0B),
                  title: 'Orders',
                  badge: '12',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to orders
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                    );
                  },
                ),
                DrawerMenuItem(
                  icon: Icons.people_rounded,
                  iconColor: Color(0xFF8B5CF6),
                  title: 'Customers',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to customers
                  },
                ),
                DrawerMenuItem(
                  icon: Icons.analytics_rounded,
                  iconColor: Color(0xFFEC4899),
                  title: 'Analytics',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to analytics
                  },
                ),
                DrawerMenuItem(
                  icon: Icons.inventory_2_rounded,
                  iconColor: Color(0xFF14B8A6),
                  title: 'Inventory',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to inventory
                  },
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(color: Color(0xFF21262D), height: 1),
                ),

                DrawerMenuItem(
                  icon: Icons.settings_rounded,
                  iconColor: Color(0xFF6B7280),
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                DrawerMenuItem(
                  icon: Icons.help_outline_rounded,
                  iconColor: Color(0xFF6B7280),
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF21262D), width: 1),
              ),
            ),
            child: Column(
              children: [
                DrawerMenuItem(
                  icon: Icons.business_rounded,
                  iconColor: Color(0xFF3B82F6),
                  title: 'Business Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BusinessProfilePage()),
                    );
                  },
                ),
                SizedBox(height: 4),
                DrawerMenuItem(
                  icon: Icons.logout_rounded,
                  iconColor: Color(0xFFEF4444),
                  title: 'Log Out',
                  titleColor: Color(0xFFEF4444),
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService().logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                ),
                SizedBox(height: 12),
                Text(
                  'Device ID: POS-0129',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.4',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Drawer Menu Item Widget
class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.badge,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF161B22) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? Colors.white,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : (isSelected
                ? Icon(Icons.chevron_right, color: Colors.grey[400], size: 20)
                : null),
      ),
    );
  }
}