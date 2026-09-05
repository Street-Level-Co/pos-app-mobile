import 'package:pos_mobile/model/country.dart';

/// Mirrors the backend `Organization` entity (`organization` table).
class Organization {
  final String? id;
  final String orgName;
  final String? orgAddress;
  final int? orgContact;
  final String? brNumber;
  final Country? country;
  final Map<String, dynamic>? additionalDeclaration;

  Organization({
    this.id,
    required this.orgName,
    this.orgAddress,
    this.orgContact,
    this.brNumber,
    this.country,
    this.additionalDeclaration,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String?,
      orgName: json['orgName'] as String,
      orgAddress: json['orgAddress'] as String?,
      orgContact: (json['orgContact'] as num?)?.toInt(),
      brNumber: json['brNumber'] as String?,
      country: json['country'] == null
          ? null
          : Country.fromJson(json['country'] as Map<String, dynamic>),
      additionalDeclaration:
          json['additionalDeclaration'] as Map<String, dynamic>?,
    );
  }
}

/// Request body for `POST /api/organization/register`.
class CreateOrganization {
  final String clientId;
  final String name;
  final String? address;
  final int? contact;
  final String? brNumber;
  final String country;
  final Map<String, bool>? additionalData;
  final Map<String, bool>? additionalValues;

  CreateOrganization({
    required this.clientId,
    required this.name,
    this.address,
    this.contact,
    this.brNumber,
    required this.country,
    this.additionalData,
    this.additionalValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientID': clientId,
      'name': name,
      if (address != null) 'address': address,
      if (contact != null) 'contact': contact,
      if (brNumber != null) 'brNumber': brNumber,
      'country': country,
      if (additionalData != null) 'additionalData': additionalData,
      if (additionalValues != null) 'additionalValues': additionalValues,
    };
  }
}

/// Request body for `POST /api/organization/register-for-user/{userId}` —
/// creates an organization and links it directly to that user (no `Client`
/// involved).
class CreateOrganizationForUser {
  final String name;
  final String? address;
  final int? contact;
  final String? brNumber;
  final String country;
  final Map<String, dynamic>? additionalDeclaration;

  CreateOrganizationForUser({
    required this.name,
    this.address,
    this.contact,
    this.brNumber,
    required this.country,
    this.additionalDeclaration,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (address != null) 'address': address,
      if (contact != null) 'contact': contact,
      if (brNumber != null) 'brNumber': brNumber,
      'country': country,
      if (additionalDeclaration != null)
        'additionalDeclaration': additionalDeclaration,
    };
  }
}

/// Request body for `PUT /api/organization/{id}`. Only non-null fields are
/// sent, so the backend leaves the rest of the organization untouched.
class UpdateOrganization {
  final String? name;
  final String? address;
  final int? contact;
  final String? brNumber;
  final String? country;
  final Map<String, dynamic>? additionalDeclaration;

  UpdateOrganization({
    this.name,
    this.address,
    this.contact,
    this.brNumber,
    this.country,
    this.additionalDeclaration,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (contact != null) 'contact': contact,
      if (brNumber != null) 'brNumber': brNumber,
      if (country != null) 'country': country,
      if (additionalDeclaration != null)
        'additionalDeclaration': additionalDeclaration,
    };
  }
}

/// Mirrors the backend `ClientOrganization` entity, returned by
/// `POST /api/organization/add-user`.
class ClientOrganization {
  final String? id;
  final String client;
  final String org;

  ClientOrganization({this.id, required this.client, required this.org});

  factory ClientOrganization.fromJson(Map<String, dynamic> json) {
    return ClientOrganization(
      id: json['id'] as String?,
      client: json['client'] as String,
      org: json['org'] as String,
    );
  }
}
