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
      ];
}
