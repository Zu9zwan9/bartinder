import 'package:equatable/equatable.dart';

/// Represents a user profile in the beerTinder app
class User extends Equatable {
  final String id;
  final String name;
  final int age;
  final String photoUrl;
  final String favoriteBeer;
  final String? bio;
  final String? lastCheckedInLocation;
  final double? lastCheckedInDistance;
  final List<String> beerPreferences;

  // Additional fields for location-based features
  final String? location; // PostGIS geography type as hex string
  final double? latitude;
  final double? longitude;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? gender;
  final String? city;
  final String? country;
  final List<String> interests;
  final DateTime? birthDate;
  final bool isPremium;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.photoUrl,
    required this.favoriteBeer,
    this.bio,
    this.lastCheckedInLocation,
    this.lastCheckedInDistance,
    this.beerPreferences = const [],
    this.location,
    this.latitude,
    this.longitude,
    this.email,
    this.phone,
    this.avatarUrl,
    this.gender,
    this.city,
    this.country,
    this.interests = const [],
    this.birthDate,
    this.isPremium = false,
    this.lastActiveAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        photoUrl,
        favoriteBeer,
        bio,
        lastCheckedInLocation,
        lastCheckedInDistance,
        beerPreferences,
        location,
        latitude,
        longitude,
        email,
        phone,
        avatarUrl,
        gender,
        city,
        country,
        interests,
        birthDate,
        isPremium,
        lastActiveAt,
      ];
}
