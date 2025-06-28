import '../entities/user_location.dart';

/// Repository interface for user location operations
abstract class UserLocationRepository {
  /// Save user's current location
  Future<void> saveUserLocation(UserLocation location);

  /// Get user's current location
  Future<UserLocation?> getCurrentUserLocation(String userId);

  /// Get user's location history
  Future<List<UserLocation>> getUserLocationHistory(String userId, {int limit = 50});

  /// Update location privacy settings
  Future<void> updateLocationPrivacy(String userId, LocationPrivacyLevel privacyLevel);

  /// Delete user's location data
  Future<void> deleteUserLocation(String userId, String locationId);

  /// Delete all user's location data
  Future<void> deleteAllUserLocations(String userId);

  /// Get users within a specific radius
  Future<List<UserLocation>> getUsersWithinRadius({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? excludeUserId,
    LocationPrivacyLevel? minPrivacyLevel,
  });

  /// Get users in the same city
  Future<List<UserLocation>> getUsersInSameCity({
    required String city,
    required String country,
    String? excludeUserId,
  });

  /// Batch update multiple user locations (for performance)
  Future<void> batchSaveUserLocations(List<UserLocation> locations);

  /// Check if user has location data
  Future<bool> hasLocationData(String userId);

  /// Get location statistics for analytics
  Future<Map<String, dynamic>> getLocationStatistics(String userId);
}
