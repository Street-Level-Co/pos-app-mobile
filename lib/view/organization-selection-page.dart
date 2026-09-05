import 'package:flutter/material.dart';

import 'package:pos_mobile/model/auth-response.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/home-page.dart';
import 'package:pos_mobile/view/organization-form-page.dart';

/// Lets the user pick which organization to work in for the session.
///
/// - [organizations] == null: reads the list cached locally from the last
///   login response (used when opened from Settings to switch).
/// - [organizations] != null: uses the list handed in directly (used right
///   after login).
/// - [isSwitching]: true when opened from Settings — pops back with `true`
///   on selection instead of navigating to [HomePage].
class OrganizationSelectionPage extends StatefulWidget {
  final List<AuthOrganization>? organizations;
  final bool isSwitching;

  const OrganizationSelectionPage({
    super.key,
    this.organizations,
    this.isSwitching = false,
  });

  @override
  State<OrganizationSelectionPage> createState() =>
      _OrganizationSelectionPageState();
}

class _OrganizationSelectionPageState extends State<OrganizationSelectionPage> {
  List<AuthOrganization> _organizations = [];
  String? _selectedOrgId;
  String? _savingOrgId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final organizations = widget.organizations ?? await TokenStorage().getOrganizations();
    final currentOrgId = await TokenStorage().getSelectedOrgId();
    if (!mounted) return;
    setState(() {
      _organizations = organizations;
      _selectedOrgId = currentOrgId;
      _isLoading = false;
    });
  }

  Future<void> _selectOrganization(AuthOrganization org) async {
    setState(() => _savingOrgId = org.id);
    await TokenStorage().saveSelectedOrganization(orgId: org.id, orgName: org.name);
    if (!mounted) return;

    if (widget.isSwitching) {
      Navigator.pop(context, true);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D1117),
        elevation: 0,
        automaticallyImplyLeading: widget.isSwitching,
        title: Text(
          'Select Organization',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    if (_organizations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.business_outlined, color: Color(0xFF3B82F6), size: 40),
              SizedBox(height: 12),
              Text(
                'No organizations found for your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrganizationFormPage(isOnboarding: !widget.isSwitching),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B82F6)),
                child: Text('Add Organization', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose which organization to work in',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _organizations.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final org = _organizations[index];
                final isSelected = org.id == _selectedOrgId;
                final isSaving = _savingOrgId == org.id;

                return Material(
                  color: Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _savingOrgId != null ? null : () => _selectOrganization(org),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Color(0xFF3B82F6) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF3B82F6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.business_rounded, color: Color(0xFF3B82F6)),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              org.name,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isSaving)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                            )
                          else if (isSelected)
                            Icon(Icons.check_circle, color: Color(0xFF3B82F6))
                          else
                            Icon(Icons.chevron_right, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
