import 'package:geolocator/geolocator.dart';
import '../../domain/entities/user_location.dart';
import '../../domain/usecases/save_user_location_usecase.dart';
import '../../domain/usecases/get_current_user_location_usecase.dart';
import '../../domain/usecases/update_location_privacy_usecase.dart';
import '../../data/repositories/user_location_repository_impl.dart';
import '../../data/services/auth_service.dart';
import 'enhanced_location_service.dart';

/// High-level service for user location operations
/// Combines location services with business logic and security
class UserLocationService {
  final EnhancedLocationService _locationService;
  final SaveUserLocationUseCase _saveLocationUseCase;
  final GetCurrentUserLocationUseCase _getCurrentLocationUseCase;
  final UpdateLocationPrivacyUseCase _updatePrivacyUseCase;

  UserLocationService({
    EnhancedLocationService? locationService,
    SaveUserLocationUseCase? saveLocationUseCase,
    GetCurrentUserLocationUseCase? getCurrentLocationUseCase,
    UpdateLocationPrivacyUseCase? updatePrivacyUseCase,
  }) : _locationService = locationService ?? EnhancedLocationService(),
       _saveLocationUseCase = saveLocationUseCase ??
           SaveUserLocationUseCase(UserLocationRepositoryImpl()),
       _getCurrentLocationUseCase = getCurrentLocationUseCase ??
           GetCurrentUserLocationUseCase(UserLocationRepositoryImpl()),
       _updatePrivacyUseCase = updatePrivacyUseCase ??
           UpdateLocationPrivacyUseCase(UserLocationRepositoryImpl());

  /// Get and save user's current location with full error handling
  Future<UserLocationResult> getCurrentLocationAndSave({
    LocationPrivacyLevel privacyLevel = LocationPrivacyLevel.city,
    LocationAccuracy accuracy = LocationAccuracy.high,
    String? locationName,
    bool forceRefresh = false,
  }) async {
    try {
      // Check if user is authenticated
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        return UserLocationResult.error(
          'User must be authenticated to save location',
          errorType: LocationErrorType.authentication,
        );
      }

      // Get current position
      final locationResult = await _locationService.getCurrentPosition(
        accuracy: accuracy,
        forceRefresh: forceRefresh,
      );

      if (locationResult.isError) {
        return UserLocationResult.error(
          locationResult.error!,
          errorType: _mapLocationErrorType(locationResult),
          shouldShowSettings: locationResult.shouldShowSettings,
        );
      }

      // Create UserLocation object
      final userLocation = await _locationService.createUserLocation(
        userId: currentUser.id,
        position: locationResult.position!,
        privacyLevel: privacyLevel,
        locationName: locationName,
        isCurrentLocation: true,
      );

      // Save location
      await _saveLocationUseCase.execute(userLocation);

      return UserLocationResult.success(userLocation);
    } catch (e) {
      return UserLocationResult.error(
        'Failed to get and save location: ${e.toString()}',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  /// Get user's saved current location
  Future<UserLocationResult> getSavedCurrentLocation([String? userId]) async {
    try {
      final targetUserId = userId ?? AuthService.currentUser?.id;
      if (targetUserId == null) {
        return UserLocationResult.error(
          'User ID is required',
          errorType: LocationErrorType.authentication,
        );
      }

      final location = await _getCurrentLocationUseCase.execute(targetUserId);
      if (location == null) {
        return UserLocationResult.error(
          'No saved location found',
          errorType: LocationErrorType.noData,
        );
      }

      return UserLocationResult.success(location);
    } catch (e) {
      return UserLocationResult.error(
        'Failed to get saved location: ${e.toString()}',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  /// Update user's location privacy settings
  Future<LocationOperationResult> updateLocationPrivacy(
    LocationPrivacyLevel privacyLevel,
  ) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        return LocationOperationResult.error(
          'User must be authenticated',
          errorType: LocationErrorType.authentication,
        );
      }

      await _updatePrivacyUseCase.execute(currentUser.id, privacyLevel);
      return LocationOperationResult.success();
    } catch (e) {
      return LocationOperationResult.error(
        'Failed to update privacy settings: ${e.toString()}',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  /// Request location permission with user-friendly messaging
  Future<LocationPermissionResult> requestLocationPermission() async {
    return await _locationService.requestLocationPermission();
  }

  /// Check if location services are available
  Future<bool> isLocationServiceEnabled() async {
    return await _locationService.isLocationServiceEnabled();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await _locationService.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await _locationService.openAppSettings();
  }

  /// Get location permission status
  Future<LocationPermission> getLocationPermission() async {
    return await _locationService.getLocationPermission();
  }

  /// Create a UserLocation from coordinates (for manual entry)
  Future<UserLocationResult> createLocationFromCoordinates({
    required double latitude,
    required double longitude,
    LocationPrivacyLevel privacyLevel = LocationPrivacyLevel.city,
    String? locationName,
  }) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        return UserLocationResult.error(
          'User must be authenticated',
          errorType: LocationErrorType.authentication,
        );
      }

      // Create a Position object for the coordinates
      final position = Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Create UserLocation
      final userLocation = await _locationService.createUserLocation(
        userId: currentUser.id,
        position: position,
        privacyLevel: privacyLevel,
        locationName: locationName,
        source: LocationSource.manual,
        isCurrentLocation: true,
      );

      // Save location
      await _saveLocationUseCase.execute(userLocation);

      return UserLocationResult.success(userLocation);
    } catch (e) {
      return UserLocationResult.error(
        'Failed to create location from coordinates: ${e.toString()}',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  /// Get address from coordinates
  Future<GeocodingResult> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return await _locationService.getAddressFromCoordinates(latitude, longitude);
  }

  /// Calculate distance between two coordinates
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return EnhancedLocationService.calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Map LocationResult error to LocationErrorType
  LocationErrorType _mapLocationErrorType(LocationResult result) {
    if (result.error?.contains('permission') == true) {
      return LocationErrorType.permission;
    }
    if (result.error?.contains('disabled') == true) {
      return LocationErrorType.serviceDisabled;
    }
    if (result.error?.contains('timeout') == true) {
      return LocationErrorType.timeout;
    }
    return LocationErrorType.unknown;
  }
}

/// Result class for user location operations
class UserLocationResult {
  final UserLocation? location;
  final String? error;
  final LocationErrorType errorType;
  final bool shouldShowSettings;

  const UserLocationResult._({
    this.location,
    this.error,
    this.errorType = LocationErrorType.unknown,
    this.shouldShowSettings = false,
  });

  factory UserLocationResult.success(UserLocation location) {
    return UserLocationResult._(location: location);
  }

  factory UserLocationResult.error(
    String error, {
    LocationErrorType errorType = LocationErrorType.unknown,
    bool shouldShowSettings = false,
  }) {
    return UserLocationResult._(
      error: error,
      errorType: errorType,
      shouldShowSettings: shouldShowSettings,
    );
  }

  bool get isSuccess => location != null && error == null;
  bool get isError => error != null;
}

/// Result class for location operations without data
class LocationOperationResult {
  final String? error;
  final LocationErrorType errorType;
  final bool shouldShowSettings;

  const LocationOperationResult._({
    this.error,
    this.errorType = LocationErrorType.unknown,
    this.shouldShowSettings = false,
  });

  factory LocationOperationResult.success() {
    return const LocationOperationResult._();
  }

  factory LocationOperationResult.error(
    String error, {
    LocationErrorType errorType = LocationErrorType.unknown,
    bool shouldShowSettings = false,
  }) {
    return LocationOperationResult._(
      error: error,
      errorType: errorType,
      shouldShowSettings: shouldShowSettings,
    );
  }

  bool get isSuccess => error == null;
  bool get isError => error != null;
}

/// Types of location errors for better error handling
enum LocationErrorType {
  permission,
  serviceDisabled,
  timeout,
  authentication,
  noData,
  network,
  unknown,
}
