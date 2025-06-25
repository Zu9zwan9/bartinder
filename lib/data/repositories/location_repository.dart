import 'package:supabase_flutter/supabase_flutter.dart';

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
    required dynamic distanceFilter,
    required String excludeUserId,
  }) async {
    // TODO: Implement this method
    return [];
  }
}
