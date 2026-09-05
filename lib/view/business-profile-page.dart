import 'package:flutter/material.dart';

import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/organization.dart';
import 'package:pos_mobile/service/organization-service.dart';
import 'package:pos_mobile/service/token-storage.dart';
import 'package:pos_mobile/view/organization-form-page.dart';

/// Resolves the organization selected for this session (if any), then hands
/// off to [OrganizationFormPage] to view/edit it — or to create one if none
/// is linked yet.
class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  bool _loading = true;
  String? _error;
  Organization? _organization;

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

      final organization = orgId == null ? null : await OrganizationService().getById(orgId);
      setState(() {
        _organization = organization;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Color(0xFF0D1117),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Business Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Color(0xFF0D1117),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Business Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
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
        ),
      );
    }

    if (_organization == null) {
      return Scaffold(
        backgroundColor: Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: Color(0xFF0D1117),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Business Profile', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_outlined, color: Colors.grey[600], size: 48),
                SizedBox(height: 16),
                Text(
                  'No organization linked to your account yet.',
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
                  label: Text('Add Organization', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (context) => OrganizationFormPage()),
                    );
                    if (created == true) _load();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return OrganizationFormPage(organization: _organization);
  }
}
