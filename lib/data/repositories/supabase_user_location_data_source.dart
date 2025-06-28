import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_location.dart';

/// Supabase data source for user location operations
class SupabaseUserLocationDataSource {
  final SupabaseClient _supabase;

  SupabaseUserLocationDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Save user location to Supabase
  Future<void> saveUserLocation(UserLocation location) async {
    try {
      // Create a JSON representation without the ID field for insertion
      // The database will auto-generate the ID
      final locationJson = location.toJson();
      locationJson.remove('id');

      await _supabase.from('user_locations').upsert(locationJson);

      // Also update the user's current location in the users table
      if (location.isCurrentLocation) {
        await _updateUserCurrentLocation(location);
      }
    } catch (e) {
      throw Exception('Failed to save user location: ${e.toString()}');
    }
  }

  /// Update user's current location in users table
  Future<void> _updateUserCurrentLocation(UserLocation location) async {
    try {
      final privacyFilteredCoords = location.privacyFilteredCoordinates;

      await _supabase.from('users').update({
        'latitude': privacyFilteredCoords['latitude'],
        'longitude': privacyFilteredCoords['longitude'],
        'city': location.locality,
        'country': location.country,
        'location_updated_at': location.timestamp.toIso8601String(),
        'location_privacy_level': location.privacyLevel.name,
      }).eq('id', location.userId);
    } catch (e) {
      // Log error but don't throw - this is a secondary operation
      print('Warning: Failed to update user current location: ${e.toString()}');
    }
  }

  /// Get user's current location
  Future<UserLocation?> getCurrentUserLocation(String userId) async {
    try {
      final response = await _supabase
          .from('user_locations')
          .select()
          .eq('user_id', userId)
          .eq('is_current_location', true)
          .order('timestamp', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      return UserLocation.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to get current user location: ${e.toString()}');
    }
  }

  /// Get user's location history
  Future<List<UserLocation>> getUserLocationHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('user_locations')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => UserLocation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user location history: ${e.toString()}');
    }
  }

  /// Update location privacy settings
  Future<void> updateLocationPrivacy(
    String userId,
    LocationPrivacyLevel privacyLevel,
  ) async {
    try {
      // Update all user locations
      await _supabase
          .from('user_locations')
          .update({'privacy_level': privacyLevel.name})
          .eq('user_id', userId);

      // Update user's current location privacy in users table
      await _supabase
          .from('users')
          .update({'location_privacy_level': privacyLevel.name})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update location privacy: ${e.toString()}');
    }
  }

  /// Delete specific user location
  Future<void> deleteUserLocation(String userId, String locationId) async {
    try {
      await _supabase
          .from('user_locations')
          .delete()
          .eq('user_id', userId)
          .eq('id', locationId);
    } catch (e) {
      throw Exception('Failed to delete user location: ${e.toString()}');
    }
  }

  /// Delete all user locations
  Future<void> deleteAllUserLocations(String userId) async {
    try {
      await _supabase
          .from('user_locations')
          .delete()
          .eq('user_id', userId);

      // Clear location data from users table
      await _supabase.from('users').update({
        'latitude': null,
        'longitude': null,
        'city': null,
        'country': null,
        'location_updated_at': null,
        'location_privacy_level': null,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete all user locations: ${e.toString()}');
    }
  }

  /// Get users within a specific radius using PostGIS functions
  Future<List<UserLocation>> getUsersWithinRadius({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? excludeUserId,
    LocationPrivacyLevel? minPrivacyLevel,
  }) async {
    try {
      // Build the query
      var query = _supabase
          .from('user_locations')
          .select()
          .eq('is_current_location', true);

      // Exclude specific user
      if (excludeUserId != null) {
        query = query.neq('user_id', excludeUserId);
      }

      // Filter by minimum privacy level
      if (minPrivacyLevel != null) {
        final allowedLevels = _getAllowedPrivacyLevels(minPrivacyLevel);
        query = query.inFilter('privacy_level', allowedLevels);
      }

      final response = await query;
      final locations = (response as List)
          .map((json) => UserLocation.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter by distance (client-side for now, could be optimized with PostGIS)
      final filteredLocations = <UserLocation>[];
      for (final location in locations) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          location.latitude,
          location.longitude,
        );

        if (distance <= radiusInKm) {
          filteredLocations.add(location.copyWith());
        }
      }

      // Sort by distance
      filteredLocations.sort((a, b) {
        final distanceA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distanceB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });

      return filteredLocations;
    } catch (e) {
      throw Exception('Failed to get users within radius: ${e.toString()}');
    }
  }

  /// Get users in the same city
  Future<List<UserLocation>> getUsersInSameCity({
    required String city,
    required String country,
    String? excludeUserId,
  }) async {
    try {
      var query = _supabase
          .from('user_locations')
          .select()
          .eq('is_current_location', true)
          .eq('locality', city)
          .eq('country', country);

      if (excludeUserId != null) {
        query = query.neq('user_id', excludeUserId);
      }

      final response = await query;
      return (response as List)
          .map((json) => UserLocation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users in same city: ${e.toString()}');
    }
  }

  /// Batch save multiple user locations
  Future<void> batchSaveUserLocations(List<UserLocation> locations) async {
    try {
      if (locations.isEmpty) return;

      final jsonList = locations.map((location) => location.toJson()).toList();
      await _supabase.from('user_locations').upsert(jsonList);

      // Update current locations in users table
      for (final location in locations.where((l) => l.isCurrentLocation)) {
        await _updateUserCurrentLocation(location);
      }
    } catch (e) {
      throw Exception('Failed to batch save user locations: ${e.toString()}');
    }
  }

  /// Check if user has location data
  Future<bool> hasLocationData(String userId) async {
    try {
      final response = await _supabase
          .from('user_locations')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check location data: ${e.toString()}');
    }
  }

  /// Get location statistics for analytics
  Future<Map<String, dynamic>> getLocationStatistics(String userId) async {
    try {
      final response = await _supabase
          .from('user_locations')
          .select('country, locality, timestamp')
          .eq('user_id', userId);

      final locations = response as List;

      if (locations.isEmpty) {
        return {
          'total_locations': 0,
          'countries_visited': 0,
          'cities_visited': 0,
          'first_location_date': null,
          'last_location_date': null,
        };
      }

      final countries = <String>{};
      final cities = <String>{};
      final timestamps = <DateTime>[];

      for (final location in locations) {
        if (location['country'] != null) {
          countries.add(location['country'] as String);
        }
        if (location['locality'] != null) {
          cities.add(location['locality'] as String);
        }
        timestamps.add(DateTime.parse(location['timestamp'] as String));
      }

      timestamps.sort();

      return {
        'total_locations': locations.length,
        'countries_visited': countries.length,
        'cities_visited': cities.length,
        'first_location_date': timestamps.first.toIso8601String(),
        'last_location_date': timestamps.last.toIso8601String(),
        'countries': countries.toList(),
        'cities': cities.toList(),
      };
    } catch (e) {
      throw Exception('Failed to get location statistics: ${e.toString()}');
    }
  }

  /// Helper method to get allowed privacy levels
  List<String> _getAllowedPrivacyLevels(LocationPrivacyLevel minLevel) {
    final allLevels = LocationPrivacyLevel.values;
    final minIndex = allLevels.indexOf(minLevel);
    return allLevels.skip(minIndex).map((level) => level.name).toList();
  }

  /// Helper method to calculate distance between two coordinates
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Helper method to convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
