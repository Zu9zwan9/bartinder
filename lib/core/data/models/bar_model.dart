import 'location_model.dart';

class BarModel {
  final String id;
  final String name;
  final LocationModel? location;
  final String? city;
  final String? country;
  final List<String>? images;
  final double? rating;
  final bool partner;
  final int? discount;
  final DateTime createdAt;

  BarModel({
    required this.id,
    required this.name,
    this.location,
    this.city,
    this.country,
    this.images,
    this.rating,
    required this.partner,
    this.discount,
    required this.createdAt,
  });

  factory BarModel.fromMap(Map<String, dynamic> map) {
    LocationModel? loc;
    if (map['location'] != null) {
      final coords = map['location'] as Map<String, dynamic>;
      loc = LocationModel.fromMap(coords);
    }
    return BarModel(
      id: map['id'] as String,
      name: map['name'] as String,
      location: loc,
      city: map['city'] as String?,
      country: map['country'] as String?,
      images: map['images'] != null
          ? List<String>.from(map['images'] as List)
          : null,
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      partner: map['partner'] as bool,
      discount: map['discount'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location?.toMap(),
      'city': city,
      'country': country,
      'images': images,
      'rating': rating,
      'partner': partner,
      'discount': discount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
