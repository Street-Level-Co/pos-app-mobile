import 'package:flutter/material.dart';

import 'package:pos_mobile/service/auth-service.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/organization-selection-page.dart';
import 'package:pos_mobile/view/sign-in-page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = true;
  String? _selectedOrgName;

  @override
  void initState() {
    super.initState();
    _loadSelectedOrganization();
  }

  Future<void> _loadSelectedOrganization() async {
    final orgName = await TokenStorage().getSelectedOrgName();
    if (!mounted) return;
    setState(() => _selectedOrgName = orgName);
  }

  Future<void> _changeOrganization() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizationSelectionPage(isSwitching: true),
      ),
    );
    if (changed == true) {
      _loadSelectedOrganization();
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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF161B22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150', // Replace with your image
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jane Doe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Store Manager',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit, color: Colors.grey[400], size: 20),
                ],
              ),
            ),

            SizedBox(height: 24),

            // GENERAL Section
            SectionHeader(title: 'GENERAL'),
            SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.business_rounded,
                  iconColor: Color(0xFF3B82F6),
                  title: 'Organization',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedOrgName ?? 'None selected',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  onTap: _changeOrganization,
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.language,
                  iconColor: Color(0xFF3B82F6),
                  title: 'Language',
                  trailing: Row(
                    children: [
                      Text(
                        'English',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  onTap: () {},
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.attach_money,
                  iconColor: Color(0xFF10B981),
                  title: 'Currency',
                  trailing: Row(
                    children: [
                      Text(
                        'USD (\$)',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  onTap: () {},
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.dark_mode,
                  iconColor: Color(0xFF8B5CF6),
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                      });
                    },
                    activeColor: Color(0xFF3B82F6),
                  ),
                  onTap: null,
                ),
              ],
            ),

            SizedBox(height: 24),

            // HARDWARE Section
            SectionHeader(title: 'HARDWARE'),
            SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.print,
                  iconColor: Color(0xFFF97316),
                  title: 'Receipt Printer',
                  subtitle: 'Connected',
                  subtitleColor: Color(0xFF10B981),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {},
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.qr_code_scanner,
                  iconColor: Color(0xFF8B5CF6),
                  title: 'Barcode Scanner',
                  trailing: Text(
                    'Setup',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () {},
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.credit_card,
                  iconColor: Color(0xFF14B8A6),
                  title: 'Card Reader',
                  trailing: Text(
                    'Searching...',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () {},
                ),
              ],
            ),

            SizedBox(height: 24),

            // SECURITY Section
            SectionHeader(title: 'SECURITY'),
            SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.admin_panel_settings,
                  iconColor: Color(0xFFEC4899),
                  title: 'Manage Roles',
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {},
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.pin,
                  iconColor: Color(0xFF6366F1),
                  title: 'Change PIN',
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: () {},
                ),
              ],
            ),

            SizedBox(height: 24),

            // SUPPORT Section
            SectionHeader(title: 'SUPPORT'),
            SizedBox(height: 12),
            SettingsCard(
              children: [
                SettingsItem(
                  icon: Icons.help_outline,
                  iconColor: Color(0xFF3B82F6),
                  title: 'Help Center',
                  trailing: Icon(Icons.open_in_new, color: Colors.grey[400], size: 20),
                  onTap: () {},
                ),
                Divider(color: Color(0xFF21262D), height: 1),
                SettingsItem(
                  icon: Icons.info_outline,
                  iconColor: Color(0xFF6B7280),
                  title: 'App Version',
                  trailing: Text(
                    'v1.0.4',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: null,
                ),
              ],
            ),

            SizedBox(height: 32),

            // Log Out Button
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.logout, color: Color(0xFFEF4444)),
                label: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Logged in as Jane Doe (Manager)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Device ID: POS-0129',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Settings Card Widget
class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// Settings Item Widget
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: subtitleColor ?? Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: subtitleColor ?? Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}