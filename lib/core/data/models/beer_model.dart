class BeerModel {
  final String id;
  final String name;
  final String? type;
  final double? abv;
  final String? brewery;
  final String? country;
  final String? imageUrl;
  final List<String>? flavorTags;
  final DateTime createdAt;

  BeerModel({
    required this.id,
    required this.name,
    this.type,
    this.abv,
    this.brewery,
    this.country,
    this.imageUrl,
    this.flavorTags,
    required this.createdAt,
  });

  factory BeerModel.fromMap(Map<String, dynamic> map) {
    return BeerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String?,
      abv: map['abv'] != null ? (map['abv'] as num).toDouble() : null,
      brewery: map['brewery'] as String?,
      country: map['country'] as String?,
      imageUrl: map['image_url'] as String?,
      flavorTags: map['flavor_tags'] != null ? List<String>.from(map['flavor_tags'] as List) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'abv': abv,
      'brewery': brewery,
      'country': country,
      'image_url': imageUrl,
      'flavor_tags': flavorTags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
