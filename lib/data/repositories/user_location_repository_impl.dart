import '../../domain/entities/user_location.dart';
import '../../domain/repositories/user_location_repository.dart';
import 'supabase_user_location_data_source.dart';

/// Implementation of UserLocationRepository using Supabase
class UserLocationRepositoryImpl implements UserLocationRepository {
  final SupabaseUserLocationDataSource _dataSource;

  UserLocationRepositoryImpl({SupabaseUserLocationDataSource? dataSource})
      : _dataSource = dataSource ?? SupabaseUserLocationDataSource();

  @override
  Future<void> saveUserLocation(UserLocation location) async {
    try {
      await _dataSource.saveUserLocation(location);
    } catch (e) {
      throw Exception('Repository: Failed to save user location - ${e.toString()}');
    }
  }

  @override
  Future<UserLocation?> getCurrentUserLocation(String userId) async {
    try {
      return await _dataSource.getCurrentUserLocation(userId);
    } catch (e) {
      throw Exception('Repository: Failed to get current user location - ${e.toString()}');
    }
  }

  @override
  Future<List<UserLocation>> getUserLocationHistory(String userId, {int limit = 50}) async {
    try {
      return await _dataSource.getUserLocationHistory(userId, limit: limit);
    } catch (e) {
      throw Exception('Repository: Failed to get user location history - ${e.toString()}');
    }
  }

  @override
  Future<void> updateLocationPrivacy(String userId, LocationPrivacyLevel privacyLevel) async {
    try {
      await _dataSource.updateLocationPrivacy(userId, privacyLevel);
    } catch (e) {
      throw Exception('Repository: Failed to update location privacy - ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserLocation(String userId, String locationId) async {
    try {
      await _dataSource.deleteUserLocation(userId, locationId);
    } catch (e) {
      throw Exception('Repository: Failed to delete user location - ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllUserLocations(String userId) async {
    try {
      await _dataSource.deleteAllUserLocations(userId);
    } catch (e) {
      throw Exception('Repository: Failed to delete all user locations - ${e.toString()}');
    }
  }

  @override
  Future<List<UserLocation>> getUsersWithinRadius({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? excludeUserId,
    LocationPrivacyLevel? minPrivacyLevel,
  }) async {
    try {
      return await _dataSource.getUsersWithinRadius(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
        excludeUserId: excludeUserId,
        minPrivacyLevel: minPrivacyLevel,
      );
    } catch (e) {
      throw Exception('Repository: Failed to get users within radius - ${e.toString()}');
    }
  }

  @override
  Future<List<UserLocation>> getUsersInSameCity({
    required String city,
    required String country,
    String? excludeUserId,
  }) async {
    try {
      return await _dataSource.getUsersInSameCity(
        city: city,
        country: country,
        excludeUserId: excludeUserId,
      );
    } catch (e) {
      throw Exception('Repository: Failed to get users in same city - ${e.toString()}');
    }
  }

  @override
  Future<void> batchSaveUserLocations(List<UserLocation> locations) async {
    try {
      await _dataSource.batchSaveUserLocations(locations);
    } catch (e) {
      throw Exception('Repository: Failed to batch save user locations - ${e.toString()}');
    }
  }

  @override
  Future<bool> hasLocationData(String userId) async {
    try {
      return await _dataSource.hasLocationData(userId);
    } catch (e) {
      throw Exception('Repository: Failed to check location data - ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getLocationStatistics(String userId) async {
    try {
      return await _dataSource.getLocationStatistics(userId);
    } catch (e) {
      throw Exception('Repository: Failed to get location statistics - ${e.toString()}');
    }
  }
}
