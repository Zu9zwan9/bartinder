import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/bar.dart';
import '../../domain/repositories/bar_repository.dart';
import '../datasources/supabase_bar_data_source.dart';
import '../services/auth_service.dart';

/// Implementation of the BarRepository interface using Supabase database
class BarRepositoryImpl implements BarRepository {
  final SupabaseBarDataSource _dataSource;
  final SupabaseClient _supabase;

  BarRepositoryImpl({SupabaseBarDataSource? dataSource})
    : _dataSource = dataSource ?? SupabaseBarDataSource(),
      _supabase = Supabase.instance.client;

  @override
  Future<List<Bar>> getBars() async {
    return await _dataSource.getBars();
  }

  @override
  Future<Bar?> getBarById(String barId) async {
    return await _dataSource.getBarById(barId);
  }

  /// Get bars within a specific distance from user location
  Future<List<Bar>> getBarsWithinDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
  }) async {
    return await _dataSource.getBarsWithinDistance(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      maxDistanceKm: maxDistanceKm,
    );
  }

  @override
  Future<void> likeBar(String barId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('bar_likes').upsert({
        'user_id': userId,
        'bar_id': barId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to like bar: $e');
    }
  }

  @override
  Future<void> dislikeBar(String barId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Remove like if it exists and add dislike
      await _supabase.from('bar_likes').delete()
          .eq('user_id', userId)
          .eq('bar_id', barId);

      await _supabase.from('bar_dislikes').upsert({
        'user_id': userId,
        'bar_id': barId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to dislike bar: $e');
    }
  }

  @override
  Future<void> checkIn(String barId) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().toIso8601String();

      await _supabase.from('bar_checkins').insert({
        'user_id': userId,
        'bar_id': barId,
        'checked_in_at': timestamp,
      });

      // Update user's last check-in location
      await _supabase.from('users').update({
        'last_checkin_bar_id': barId,
        'last_checkin_at': timestamp,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to check in to bar: $e');
    }
  }

  @override
  Future<List<Bar>> getBarsWithPlannedVisits() async {
    return await _dataSource.getBarsWithPlannedVisits();
  }
}
