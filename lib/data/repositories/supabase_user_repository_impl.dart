import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../datasources/mock_user_data_source.dart';

class SupabaseUserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final MockUserDataSource _mockDataSource = MockUserDataSource();

  String get _currentUserId {
    final id = AuthService.currentUserId;
    if (id == null) throw Exception('Not signed in');
    return id;
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final currentId = _currentUserId;
      final data = await _supabase.from('users').select();

      // If no users found in database, populate with test users
      if ((data as List<dynamic>).isEmpty) {
        await _populateTestUsers();
        final newData = await _supabase.from('users').select();
        return (newData as List<dynamic>).map((row) {
          final map = row as Map<String, dynamic>;
          return User(
            id: map['id']?.toString() ?? '',
            name: map['name']?.toString() ?? 'Unknown',
            age: (map['age'] as int?) ?? 0,
            photoUrl: map['photo_url']?.toString() ?? '',
            favoriteBeer: map['favorite_beer']?.toString() ?? 'Unknown',
            bio: map['bio']?.toString(),
            lastCheckedInLocation: map['last_checked_in_location']?.toString(),
            lastCheckedInDistance: (map['last_checked_in_distance'] as num?)?.toDouble(),
            beerPreferences: List<String>.from(map['beer_preferences'] ?? []),
          );
        }).where((u) => u.id != currentId).toList();
      }

      return (data as List<dynamic>).map((row) {
        final map = row as Map<String, dynamic>;
        return User(
          id: map['id'] as String,
          name: map['name'] as String,
          age: map['age'] as int,
          photoUrl: map['photo_url'] as String,
          favoriteBeer: map['favorite_beer'] as String,
          bio: map['bio'] as String?,
          lastCheckedInLocation: map['last_checked_in_location'] as String?,
          lastCheckedInDistance: (map['last_checked_in_distance'] as num?)?.toDouble(),
          beerPreferences: List<String>.from(map['beer_preferences'] ?? []),
        );
      }).where((u) => u.id != currentId).toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  @override
  Future<void> likeUser(String userId) async {
    try {
      final currentId = _currentUserId;
      await _supabase.from('user_likes').insert({
        'from_user': currentId,
        'to_user': userId,
      });
    } catch (e) {
      throw Exception('Error liking user: $e');
    }
  }

  @override
  Future<void> dislikeUser(String userId) async {
    try {
      final currentId = _currentUserId;
      await _supabase.from('user_likes')
          .delete()
          .eq('from_user', currentId)
          .eq('to_user', userId);
    } catch (e) {
      throw Exception('Error disliking user: $e');
    }
  }

  @override
  Future<List<String>> getMatches() async {
    try {
      final currentId = _currentUserId;
      final likesData = await _supabase.from('user_likes').select('to_user').eq('from_user', currentId);
      final likedIds = (likesData as List<dynamic>).map((e) => e['to_user'] as String);
      final matches = <String>[];
      for (var toId in likedIds) {
        final mutualData = await _supabase.from('user_likes')
            .select()
            .eq('from_user', toId)
            .eq('to_user', currentId);
        if ((mutualData as List<dynamic>).isNotEmpty) matches.add(toId);
      }
      return matches;
    } catch (e) {
      throw Exception('Error getting matches: $e');
    }
  }

  /// Populate the database with test users from mock data source
  Future<void> _populateTestUsers() async {
    try {
      final mockUsers = _mockDataSource.getUsers();
      final usersData = mockUsers.map((user) => {
        'id': user.id,
        'name': user.name,
        'age': user.age,
        'photo_url': user.photoUrl,
        'favorite_beer': user.favoriteBeer,
        'bio': user.bio,
        'last_checked_in_location': user.lastCheckedInLocation,
        'last_checked_in_distance': user.lastCheckedInDistance,
        'beer_preferences': user.beerPreferences,
      }).toList();

      await _supabase.from('users').insert(usersData);
    } catch (e) {
      // If insertion fails (e.g., users already exist), we can ignore the error
      if (kDebugMode) {
        print('Error populating test users: $e');
      }
    }
  }
}
