part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class GetAndSaveLocationEvent extends LocationEvent {}

class FindUsersNearbyEvent extends LocationEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;

  const FindUsersNearbyEvent({
    required this.latitude,
    required this.longitude,
    this.radiusInKm = 10,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm];
}

class FindUsersByDistanceFilterEvent extends LocationEvent {
  final double latitude;
  final double longitude;
  final DistanceFilter distanceFilter;

  const FindUsersByDistanceFilterEvent({
    required this.latitude,
    required this.longitude,
    required this.distanceFilter,
  });

  @override
  List<Object?> get props => [latitude, longitude, distanceFilter];
}
