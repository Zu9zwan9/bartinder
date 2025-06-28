import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/user_location.dart';
import 'package:uuid/uuid.dart';

/// Enhanced location service with production-ready features
/// Follows Apple HIG guidelines for location services
class EnhancedLocationService {
  static const _uuid = Uuid();

  // Cache for geocoding results to reduce API calls
  static final Map<String, Placemark> _geocodingCache = {};

  // Location settings optimized for battery life and accuracy
  static const LocationSettings _highAccuracySettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Update every 10 meters
    timeLimit: Duration(seconds: 30), // Timeout after 30 seconds
  );

  static const LocationSettings _balancedSettings = LocationSettings(
    accuracy: LocationAccuracy.medium,
    distanceFilter: 50, // Update every 50 meters
    timeLimit: Duration(seconds: 15),
  );

  static const LocationSettings _lowPowerSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100, // Update every 100 meters
    timeLimit: Duration(seconds: 10),
  );

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Get current location permission status
  Future<LocationPermission> getLocationPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      return LocationPermission.denied;
    }
  }

  /// Request location permission with proper error handling
  /// Follows Apple HIG guidelines for permission requests
  Future<LocationPermissionResult> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult(
          permission: LocationPermission.denied,
          canRequest: false,
          message: 'Location services are disabled. Please enable them in Settings.',
          shouldShowSettings: true,
        );
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult(
          permission: permission,
          canRequest: false,
          message: 'Location permissions are permanently denied. Please enable them in Settings.',
          shouldShowSettings: true,
        );
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return LocationPermissionResult(
            permission: permission,
            canRequest: true,
            message: 'Location permission is required to find nearby places and users.',
            shouldShowSettings: false,
          );
        }

        if (permission == LocationPermission.deniedForever) {
          return LocationPermissionResult(
            permission: permission,
            canRequest: false,
            message: 'Location permissions are permanently denied. Please enable them in Settings.',
            shouldShowSettings: true,
          );
        }
      }

      return LocationPermissionResult(
        permission: permission,
        canRequest: false,
        message: 'Location permission granted.',
        shouldShowSettings: false,
      );
    } catch (e) {
      return LocationPermissionResult(
        permission: LocationPermission.denied,
        canRequest: false,
        message: 'Error requesting location permission: ${e.toString()}',
        shouldShowSettings: false,
      );
    }
  }

  /// Get current position with enhanced error handling and battery optimization
  Future<LocationResult> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    bool forceRefresh = false,
  }) async {
    try {
      // Check permissions first
      final permissionResult = await requestLocationPermission();
      if (!permissionResult.isGranted) {
        return LocationResult.error(
          'Location permission not granted: ${permissionResult.message}',
          shouldShowSettings: permissionResult.shouldShowSettings,
        );
      }

      // Select appropriate settings based on accuracy requirement
      LocationSettings settings;
      switch (accuracy) {
        case LocationAccuracy.high:
        case LocationAccuracy.best:
        case LocationAccuracy.bestForNavigation:
          settings = _highAccuracySettings;
          break;
        case LocationAccuracy.medium:
          settings = _balancedSettings;
          break;
        case LocationAccuracy.low:
        case LocationAccuracy.lowest:
          settings = _lowPowerSettings;
          break;
        case LocationAccuracy.reduced:
          settings = _lowPowerSettings;
          break;
      }

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      return LocationResult.success(position);
    } on TimeoutException {
      return LocationResult.error(
        'Location request timed out. Please try again.',
      );
    } on LocationServiceDisabledException {
      return LocationResult.error(
        'Location services are disabled. Please enable them in Settings.',
        shouldShowSettings: true,
      );
    } on PermissionDeniedException {
      return LocationResult.error(
        'Location permission denied. Please grant permission in Settings.',
        shouldShowSettings: true,
      );
    } catch (e) {
      return LocationResult.error(
        'Failed to get location: ${e.toString()}',
      );
    }
  }

  /// Convert coordinates to address using geocoding
  Future<GeocodingResult> getAddressFromCoordinates(
    double latitude,
    double longitude, {
    bool useCache = true,
  }) async {
    try {
      final cacheKey = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

      // Check cache first
      if (useCache && _geocodingCache.containsKey(cacheKey)) {
        return GeocodingResult.success(_geocodingCache[cacheKey]!);
      }

      // Perform geocoding
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Geocoding request timed out'),
      );

      if (placemarks.isEmpty) {
        return GeocodingResult.error('No address found for the given coordinates');
      }

      final placemark = placemarks.first;

      // Cache the result
      if (useCache) {
        _geocodingCache[cacheKey] = placemark;
      }

      return GeocodingResult.success(placemark);
    } on TimeoutException {
      return GeocodingResult.error('Address lookup timed out. Please try again.');
    } catch (e) {
      return GeocodingResult.error('Failed to get address: ${e.toString()}');
    }
  }

  /// Create UserLocation from Position and Placemark
  Future<UserLocation> createUserLocation({
    required String userId,
    required Position position,
    Placemark? placemark,
    LocationPrivacyLevel privacyLevel = LocationPrivacyLevel.city,
    LocationSource source = LocationSource.gps,
    String? locationName,
    bool isCurrentLocation = true,
  }) async {
    // If placemark is not provided, try to get it
    Placemark? addressInfo = placemark;
    if (addressInfo == null) {
      final geocodingResult = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (geocodingResult.isSuccess) {
        addressInfo = geocodingResult.placemark;
      }
    }

    return UserLocation(
      id: _uuid.v4(),
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      country: addressInfo?.country,
      administrativeArea: addressInfo?.administrativeArea,
      locality: addressInfo?.locality,
      subLocality: addressInfo?.subLocality,
      thoroughfare: addressInfo?.thoroughfare,
      subThoroughfare: addressInfo?.subThoroughfare,
      postalCode: addressInfo?.postalCode,
      isoCountryCode: addressInfo?.isoCountryCode,
      timestamp: DateTime.now(),
      isCurrentLocation: isCurrentLocation,
      locationName: locationName,
      privacyLevel: privacyLevel,
      source: source,
    );
  }

  /// Get position stream for real-time location updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.medium,
  }) {
    LocationSettings settings;
    switch (accuracy) {
      case LocationAccuracy.high:
      case LocationAccuracy.best:
      case LocationAccuracy.bestForNavigation:
        settings = _highAccuracySettings;
        break;
      case LocationAccuracy.medium:
        settings = _balancedSettings;
        break;
      case LocationAccuracy.low:
      case LocationAccuracy.lowest:
        settings = _lowPowerSettings;
        break;
      case LocationAccuracy.reduced:
        settings = _lowPowerSettings;
        break;
    }

    return Geolocator.getPositionStream(locationSettings: settings);
  }

  /// Calculate distance between two coordinates
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert to kilometers
  }

  /// Calculate distance in meters
  static double calculateDistanceInMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  /// Open app-specific location settings
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  /// Clear geocoding cache
  static void clearGeocodingCache() {
    _geocodingCache.clear();
  }

  /// Get cache size for debugging
  static int getCacheSize() {
    return _geocodingCache.length;
  }
}

/// Result class for location operations
class LocationResult {
  final Position? position;
  final String? error;
  final bool shouldShowSettings;

  const LocationResult._({
    this.position,
    this.error,
    this.shouldShowSettings = false,
  });

  factory LocationResult.success(Position position) {
    return LocationResult._(position: position);
  }

  factory LocationResult.error(String error, {bool shouldShowSettings = false}) {
    return LocationResult._(
      error: error,
      shouldShowSettings: shouldShowSettings,
    );
  }

  bool get isSuccess => position != null && error == null;
  bool get isError => error != null;
}

/// Result class for geocoding operations
class GeocodingResult {
  final Placemark? placemark;
  final String? error;

  const GeocodingResult._({this.placemark, this.error});

  factory GeocodingResult.success(Placemark placemark) {
    return GeocodingResult._(placemark: placemark);
  }

  factory GeocodingResult.error(String error) {
    return GeocodingResult._(error: error);
  }

  bool get isSuccess => placemark != null && error == null;
  bool get isError => error != null;
}

/// Result class for permission requests
class LocationPermissionResult {
  final LocationPermission permission;
  final bool canRequest;
  final String message;
  final bool shouldShowSettings;

  const LocationPermissionResult({
    required this.permission,
    required this.canRequest,
    required this.message,
    required this.shouldShowSettings,
  });

  bool get isGranted =>
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;

  bool get isDenied => permission == LocationPermission.denied;
  bool get isDeniedForever => permission == LocationPermission.deniedForever;
}
