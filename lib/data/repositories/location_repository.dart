import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/distance_filter.dart';
import '../../core/services/location_service.dart';

class LocationRepository {
  final SupabaseClient supabase;

  LocationRepository({SupabaseClient? supabase})
    : supabase = supabase ?? Supabase.instance.client;

  Future<void> saveUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    await supabase.from('users').upsert({
      'id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveUserDataWithLocation({
    required String userId,
    required String name,
    required String age,
    required String email,
    required double latitude,
    required double longitude,
  }) async {
    await supabase.from('users').upsert({
      'id': userId,
      'name': name,
      'age': age,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getUsersNearby({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    // Пример простой фильтрации по диапазону координат
    final double latDelta = radiusInKm / 111.0;
    final double lngDelta =
        radiusInKm / (111.0 * (latitude.abs() > 0 ? latitude.abs() : 1));
    final response = await supabase
        .from('users')
        .select()
        .gte('latitude', latitude - latDelta)
        .lte('latitude', latitude + latDelta);
    final users = (response as List).where((data) {
      final double userLng = (data['longitude'] ?? 0.0) * 1.0;
      return userLng > longitude - lngDelta && userLng < longitude + lngDelta;
    }).toList();
    return List<Map<String, dynamic>>.from(users);
  }

  Future<List<Map<String, dynamic>>> getUsersByDistanceFilter({
    required double latitude,
    required double longitude,
    required DistanceFilter distanceFilter,
    required String excludeUserId,
  }) async {
    try {
      // Get all users with location data, excluding the current user
      final response = await supabase
          .from('users_with_location')
          .select()
          .neq('id', excludeUserId)
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      final users = List<Map<String, dynamic>>.from(response as List);

      // Filter users based on distance criteria
      final filteredUsers = <Map<String, dynamic>>[];

      for (final user in users) {
        final userLat = (user['latitude'] as num?)?.toDouble();
        final userLng = (user['longitude'] as num?)?.toDouble();

        if (userLat == null || userLng == null) continue;

        final distance = LocationService.calculateDistance(
          latitude,
          longitude,
          userLat,
          userLng,
        );

        bool shouldInclude = false;

        switch (distanceFilter) {
          case DistanceFilter.nearby100m:
            shouldInclude = distance <= 0.1; // 100m = 0.1km
            break;
          case DistanceFilter.nearby250m:
            shouldInclude = distance <= 0.25; // 250m = 0.25km
            break;
          case DistanceFilter.nearby500m:
            shouldInclude = distance <= 0.5; // 500m = 0.5km
            break;
          case DistanceFilter.inMyCity:
            // For city-based filtering, we'll use a 50km radius as approximation
            // In a real app, this would check city names or use proper geographic boundaries
            shouldInclude = distance <= 50;
            break;
          case DistanceFilter.inNearbyCity:
            // Nearby cities: between 50km and 200km
            shouldInclude = distance > 50 && distance <= 200;
            break;
          case DistanceFilter.inOtherCountry:
            // Other countries: more than 200km (simplified)
            shouldInclude = distance > 200;
            break;
        }

        if (shouldInclude) {
          // Add distance to user data
          user['distance'] = distance;
          filteredUsers.add(user);
        }
      }

      // Sort by distance (closest first)
      filteredUsers.sort((a, b) {
        final distanceA = (a['distance'] as double?) ?? double.infinity;
        final distanceB = (b['distance'] as double?) ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      return filteredUsers;
    } catch (e) {
      print('Error filtering users by distance: $e');
      return [];
    }
  }
}
