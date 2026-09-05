/// Mirrors the backend `Country` entity (`country` table: `country_id`,
/// `country_name`).
class Country {
  final String? id;
  final String countryName;

  Country({this.id, required this.countryName});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String?,
      countryName: json['countryName'] as String,
    );
  }
}
