import 'package:flutter/material.dart';

import 'package:pos_mobile/exception/api-exception.dart';
import 'package:pos_mobile/model/country.dart';
import 'package:pos_mobile/model/organization.dart';
import 'package:pos_mobile/service/auth-service.dart';
import 'package:pos_mobile/service/country-service.dart';
import 'package:pos_mobile/service/organization-service.dart';
import 'package:pos_mobile/view/home-page.dart';

/// Create/edit form for an organization's business profile.
///
/// - [organization] == null: create mode, linked to the current user
///   (`POST /api/organization/register-for-user/{userId}`).
/// - [organization] != null: edit mode
///   (`PUT /api/organization/{id}`).
///
/// [isOnboarding] marks the post-login "you have no organization yet" flow:
/// it swaps the Cancel action for "Skip for now" and lands on [HomePage]
/// after a save instead of popping back.
class OrganizationFormPage extends StatefulWidget {
  final Organization? organization;
  final bool isOnboarding;

  const OrganizationFormPage({super.key, this.organization, this.isOnboarding = false});

  @override
  State<OrganizationFormPage> createState() => _OrganizationFormPageState();
}

class _OrganizationFormPageState extends State<OrganizationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _brNumberController = TextEditingController();

  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;
  bool _isSaving = false;

  bool get _isEditing => widget.organization != null;

  @override
  void initState() {
    super.initState();
    final org = widget.organization;
    if (org != null) {
      _nameController.text = org.orgName;
      _addressController.text = org.orgAddress ?? '';
      _contactController.text = org.orgContact?.toString() ?? '';
      _brNumberController.text = org.brNumber ?? '';
    }
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await CountryService().getAll();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        final currentCountryId = widget.organization?.country?.id;
        for (final c in countries) {
          if (c.id == currentCountryId) {
            _selectedCountry = c;
            break;
          }
        }
        _isLoadingCountries = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCountries = false);
      _showError(e.message);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _brNumberController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Color(0xFFEF4444)),
    );
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Organization name is required');
      return;
    }
    if (_selectedCountry?.id == null) {
      _showError('Country is required');
      return;
    }

    final contactText = _contactController.text.trim();
    final contact = contactText.isEmpty ? null : int.tryParse(contactText);
    if (contactText.isNotEmpty && contact == null) {
      _showError('Enter a valid contact number');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        await OrganizationService().update(
          widget.organization!.id!,
          UpdateOrganization(
            name: _nameController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            contact: contact,
            brNumber: _brNumberController.text.trim().isEmpty
                ? null
                : _brNumberController.text.trim(),
            country: _selectedCountry!.id,
          ),
        );
      } else {
        final userId = await AuthService().currentUserId();
        if (userId == null) {
          _showError('You need to be logged in to add an organization');
          return;
        }
        await OrganizationService().createForUser(
          userId,
          CreateOrganizationForUser(
            name: _nameController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            contact: contact,
            brNumber: _brNumberController.text.trim().isEmpty
                ? null
                : _brNumberController.text.trim(),
            country: _selectedCountry!.id!,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Business profile updated!' : 'Organization created!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      if (widget.isOnboarding) {
        _goHome();
      } else {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D1117),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.isOnboarding
            ? null
            : TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ),
        leadingWidth: widget.isOnboarding ? 0 : 80,
        title: Text(
          _isEditing ? 'Business Profile' : 'Add Organization',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: widget.isOnboarding
            ? [
                TextButton(
                  onPressed: _isSaving ? null : _goHome,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isOnboarding) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF3B82F6), width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No organization is linked to your account yet. Add one to continue.',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],

                    Text(
                      'Business Details',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    Text('Organization Name *', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., Downtown Coffee House',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Color(0xFF161B22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text('Country *', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isLoadingCountries ? null : _showCountryPicker,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isLoadingCountries
                                  ? 'Loading countries...'
                                  : (_selectedCountry?.countryName ?? 'Select country'),
                              style: TextStyle(
                                color: _selectedCountry != null ? Colors.white : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            _isLoadingCountries
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[500]),
                                  )
                                : Icon(Icons.chevron_right, color: Colors.grey[500]),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text('Contact Number', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g., 94771234567',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Color(0xFF161B22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text('Business Registration Number', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _brNumberController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., BR-2024-00123',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Color(0xFF161B22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text('Address', style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      style: TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Street, city, postal code...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Color(0xFF161B22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),

                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF0D1117),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, -5)),
                ],
              ),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isSaving ? null : _save,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isSaving
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, color: Colors.white, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  _isEditing ? 'Save Changes' : 'Create Organization',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(height: 20),
              Text(
                'Select Country',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      title: Text(country.countryName, style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() => _selectedCountry = country);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
