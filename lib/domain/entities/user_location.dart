class UserLocation {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? country;
  final String? administrativeArea; // State/Province
  final String? locality; // City
  final String? subLocality; // District/Neighborhood
  final String? thoroughfare; // Street name
  final String? subThoroughfare; // Street number
  final String? postalCode;
  final String? isoCountryCode;
  final DateTime timestamp;
  final bool isCurrentLocation;
  final String? locationName; // Custom name for the location
  final LocationPrivacyLevel privacyLevel;
  final LocationSource source;

  const UserLocation({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.country,
    this.administrativeArea,
    this.locality,
    this.subLocality,
    this.thoroughfare,
    this.subThoroughfare,
    this.postalCode,
    this.isoCountryCode,
    required this.timestamp,
    this.isCurrentLocation = false,
    this.locationName,
    this.privacyLevel = LocationPrivacyLevel.city,
    this.source = LocationSource.gps,
  });

  /// Get formatted address string
  String get formattedAddress {
    final parts = <String>[];

    if (subThoroughfare != null && thoroughfare != null) {
      parts.add('$subThoroughfare $thoroughfare');
    } else if (thoroughfare != null) {
      parts.add(thoroughfare!);
    }

    if (subLocality != null) {
      parts.add(subLocality!);
    }

    if (locality != null) {
      parts.add(locality!);
    }

    if (administrativeArea != null) {
      parts.add(administrativeArea!);
    }

    if (country != null) {
      parts.add(country!);
    }

    return parts.join(', ');
  }

  /// Get privacy-filtered address based on privacy level
  String get privacyFilteredAddress {
    switch (privacyLevel) {
      case LocationPrivacyLevel.exact:
        return formattedAddress;
      case LocationPrivacyLevel.street:
        final parts = <String>[];
        if (thoroughfare != null) parts.add(thoroughfare!);
        if (locality != null) parts.add(locality!);
        if (administrativeArea != null) parts.add(administrativeArea!);
        if (country != null) parts.add(country!);
        return parts.join(', ');
      case LocationPrivacyLevel.city:
        final parts = <String>[];
        if (locality != null) parts.add(locality!);
        if (administrativeArea != null) parts.add(administrativeArea!);
        if (country != null) parts.add(country!);
        return parts.join(', ');
      case LocationPrivacyLevel.region:
        final parts = <String>[];
        if (administrativeArea != null) parts.add(administrativeArea!);
        if (country != null) parts.add(country!);
        return parts.join(', ');
      case LocationPrivacyLevel.country:
        return country ?? 'Unknown';
      case LocationPrivacyLevel.hidden:
        return 'Location hidden';
    }
  }

  /// Get privacy-filtered coordinates
  Map<String, double?> get privacyFilteredCoordinates {
    switch (privacyLevel) {
      case LocationPrivacyLevel.exact:
        return {'latitude': latitude, 'longitude': longitude};
      case LocationPrivacyLevel.street:
        // Round to ~100m precision
        return {
          'latitude': double.parse(latitude.toStringAsFixed(3)),
          'longitude': double.parse(longitude.toStringAsFixed(3)),
        };
      case LocationPrivacyLevel.city:
        // Round to ~1km precision
        return {
          'latitude': double.parse(latitude.toStringAsFixed(2)),
          'longitude': double.parse(longitude.toStringAsFixed(2)),
        };
      case LocationPrivacyLevel.region:
      case LocationPrivacyLevel.country:
      case LocationPrivacyLevel.hidden:
        return {'latitude': null, 'longitude': null};
    }
  }

  UserLocation copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? country,
    String? administrativeArea,
    String? locality,
    String? subLocality,
    String? thoroughfare,
    String? subThoroughfare,
    String? postalCode,
    String? isoCountryCode,
    DateTime? timestamp,
    bool? isCurrentLocation,
    String? locationName,
    LocationPrivacyLevel? privacyLevel,
    LocationSource? source,
  }) {
    return UserLocation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      country: country ?? this.country,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      locality: locality ?? this.locality,
      subLocality: subLocality ?? this.subLocality,
      thoroughfare: thoroughfare ?? this.thoroughfare,
      subThoroughfare: subThoroughfare ?? this.subThoroughfare,
      postalCode: postalCode ?? this.postalCode,
      isoCountryCode: isoCountryCode ?? this.isoCountryCode,
      timestamp: timestamp ?? this.timestamp,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      locationName: locationName ?? this.locationName,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'country': country,
      'administrative_area': administrativeArea,
      'locality': locality,
      'sub_locality': subLocality,
      'thoroughfare': thoroughfare,
      'sub_thoroughfare': subThoroughfare,
      'postal_code': postalCode,
      'iso_country_code': isoCountryCode,
      'timestamp': timestamp.toIso8601String(),
      'is_current_location': isCurrentLocation,
      'location_name': locationName,
      'privacy_level': privacyLevel.name,
      'source': source.name,
    };
  }

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      country: json['country'] as String?,
      administrativeArea: json['administrative_area'] as String?,
      locality: json['locality'] as String?,
      subLocality: json['sub_locality'] as String?,
      thoroughfare: json['thoroughfare'] as String?,
      subThoroughfare: json['sub_thoroughfare'] as String?,
      postalCode: json['postal_code'] as String?,
      isoCountryCode: json['iso_country_code'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isCurrentLocation: json['is_current_location'] as bool? ?? false,
      locationName: json['location_name'] as String?,
      privacyLevel: LocationPrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacy_level'],
        orElse: () => LocationPrivacyLevel.city,
      ),
      source: LocationSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => LocationSource.gps,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLocation &&
        other.id == id &&
        other.userId == userId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(id, userId, latitude, longitude, timestamp);
  }

  @override
  String toString() {
    return 'UserLocation(id: $id, userId: $userId, location: $privacyFilteredAddress, timestamp: $timestamp)';
  }
}

enum LocationPrivacyLevel {
  exact,     // Full address with street number
  street,    // Street level without number
  city,      // City level only
  region,    // State/Province level
  country,   // Country level only
  hidden,    // Location completely hidden
}

enum LocationSource {
  gps,       // GPS/GNSS
  network,   // Network-based location
  manual,    // Manually entered by user
  imported,  // Imported from external source
}
