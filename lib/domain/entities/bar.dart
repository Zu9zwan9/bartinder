import 'package:equatable/equatable.dart';

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
  final String? crowdLevel; // e.g., "Low", "Medium", "High"
  final List<String> usersHeadingThere; // IDs of users heading to this bar
  final List<Event>? events; // Live events at the bar

  const Bar({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.crowdLevel,
    this.photoUrl,
    this.description,
    this.beerTypes = const [],
    this.hasDiscount = false,
    this.discountPercentage,
    this.plannedVisitorsCount,
    this.usersHeadingThere = const [],
    this.events,
  });

  /// Creates a copy of the current [Bar] instance with the given fields replaced by new values.
  /// Only the [distance] field is mutable.
  Bar copyWith({
    double? distance,
  }) {
    return Bar(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distance: distance ?? this.distance,
      photoUrl: photoUrl,
      description: description,
      beerTypes: beerTypes,
      hasDiscount: hasDiscount,
      discountPercentage: discountPercentage,
      plannedVisitorsCount: plannedVisitorsCount,
      crowdLevel: crowdLevel,
      usersHeadingThere: usersHeadingThere,
      events: events,
    );
  }

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
    crowdLevel,
    usersHeadingThere,
    events,
  ];
}

/// Represents an event at a bar
class Event extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;

  const Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [id, name, description, startTime, endTime];
}
