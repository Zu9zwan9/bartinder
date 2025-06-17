import 'package:equatable/equatable.dart';

/// Represents a bar or venue in the beerTinder app
class Bar extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance; // Distance from user's current location
  final String? photoUrl;
  final String? description;
  final List<String> beerTypes;
  final bool hasDiscount; // Whether the bar offers discounts for app users
  final int? discountPercentage;
  final int? plannedVisitorsCount; // Number of users planning to visit

  const Bar({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.photoUrl,
    this.description,
    this.beerTypes = const [],
    this.hasDiscount = false,
    this.discountPercentage,
    this.plannedVisitorsCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        distance,
        photoUrl,
        description,
        beerTypes,
        hasDiscount,
        discountPercentage,
        plannedVisitorsCount,
      ];
}
