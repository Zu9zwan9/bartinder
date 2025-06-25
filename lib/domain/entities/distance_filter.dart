/// Distance filter options for finding nearby users
enum DistanceFilter {
  /// Users within 100 meters
  nearby100m,

  /// Users within 250 meters
  nearby250m,

  /// Users within 500 meters
  nearby500m,

  /// Users in the same city
  inMyCity,

  /// Users in nearby cities (within 50km but different city)
  inNearbyCity,

  /// Users in other countries
  inOtherCountry,
}

extension DistanceFilterExtension on DistanceFilter {
  /// Get display name for the distance filter
  String get displayName {
    switch (this) {
      case DistanceFilter.nearby100m:
        return '100m';
      case DistanceFilter.nearby250m:
        return '250m';
      case DistanceFilter.nearby500m:
        return '500m';
      case DistanceFilter.inMyCity:
        return 'In my city';
      case DistanceFilter.inNearbyCity:
        return 'Nearby cities';
      case DistanceFilter.inOtherCountry:
        return 'Other countries';
    }
  }

  /// Get description for the distance filter
  String get description {
    switch (this) {
      case DistanceFilter.nearby100m:
        return 'Users within 100 meters';
      case DistanceFilter.nearby250m:
        return 'Users within 250 meters';
      case DistanceFilter.nearby500m:
        return 'Users within 500 meters';
      case DistanceFilter.inMyCity:
        return 'Users in the same city';
      case DistanceFilter.inNearbyCity:
        return 'Users in nearby cities (within 50km)';
      case DistanceFilter.inOtherCountry:
        return 'Users in other countries';
    }
  }

  /// Get icon name for the distance filter
  String get iconName {
    switch (this) {
      case DistanceFilter.nearby100m:
      case DistanceFilter.nearby250m:
      case DistanceFilter.nearby500m:
        return 'location.circle';
      case DistanceFilter.inMyCity:
        return 'building.2';
      case DistanceFilter.inNearbyCity:
        return 'map';
      case DistanceFilter.inOtherCountry:
        return 'globe';
    }
  }
}
