import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart' as app_user;
import '../../domain/repositories/user_repository.dart';
import '../services/auth_service.dart';

/// Implementation of the UserRepository interface using Supabase database
class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;

  UserRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<app_user.User>> getUsers() async {
    try {
      final currentUserId = AuthService.currentUserId;
      final response = await _supabase
          .from('users_with_location')
          .select()
          .neq('id', currentUserId ?? '')
          .limit(100);

      final List<dynamic> data = response as List<dynamic>;

      final users = data
          .map(
            (item) => app_user.User(
              id: item['id']?.toString() ?? '',
              name: item['name'] ?? '',
              age: int.tryParse(item['age']?.toString() ?? '') ?? 0,
              photoUrl: item['photoUrl'] ?? item['avatar_url'] ?? '',
              favoriteBeer: item['favoriteBeer'] ?? '',
              bio: item['bio'],
              lastCheckedInLocation: item['lastCheckedInLocation'],
              lastCheckedInDistance: (item['lastCheckedInDistance'] is num)
                  ? (item['lastCheckedInDistance'] as num).toDouble()
                  : null,
              beerPreferences: (item['beerPreferences'] is List)
                  ? List<String>.from(item['beerPreferences'])
                  : (item['interests'] is List)
                      ? List<String>.from(item['interests'])
                      : [],
              latitude: (item['latitude'] as num?)?.toDouble(),
              longitude: (item['longitude'] as num?)?.toDouble(),
              email: item['email'],
              phone: item['phone'],
              avatarUrl: item['avatar_url'],
              gender: item['gender'],
              city: item['city'],
              country: item['country'],
              interests: (item['interests'] is List)
                  ? List<String>.from(item['interests'])
                  : [],
              birthDate: item['birth_date'] != null
                  ? DateTime.tryParse(item['birth_date'])
                  : null,
              isPremium: item['is_premium'] ?? false,
              lastActiveAt: item['last_active_at'] != null
                  ? DateTime.tryParse(item['last_active_at'])
                  : null,
            ),
          )
          .toList();
      return users;
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  @override
  Future<void> likeUser(String userId) async {
    try {
      final currentUserId = AuthService.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      await _supabase.from('likes').upsert({
        'from_user': currentUserId,
        'to_user': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to like user: $e');
    }
  }

  @override
  Future<void> dislikeUser(String userId) async {
    try {
      final currentUserId = AuthService.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Remove like if it exists
      await _supabase.from('likes').delete()
          .eq('from_user', currentUserId)
          .eq('to_user', userId);

      // Add dislike record
      await _supabase.from('dislikes').upsert({
        'from_user': currentUserId,
        'to_user': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to dislike user: $e');
    }
  }

  @override
  Future<List<String>> getMatches() async {
    try {
      final currentUserId = AuthService.currentUserId;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Get users that current user liked
      final outgoingLikes = await _supabase
          .from('likes')
          .select('to_user')
          .eq('from_user', currentUserId);

      final likedUserIds = (outgoingLikes as List<dynamic>)
          .map((e) => e['to_user'] as String)
          .toList();

      if (likedUserIds.isEmpty) return [];

      // Get users that liked current user back (mutual likes)
      final incomingLikes = await _supabase
          .from('likes')
          .select('from_user')
          .eq('to_user', currentUserId)
          .inFilter('from_user', likedUserIds);

      final matchedUserIds = (incomingLikes as List<dynamic>)
          .map((e) => e['from_user'] as String)
          .toList();

      return matchedUserIds;
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }

  // Добавим метод для сохранения пользователя в Supabase
  Future<void> saveUserWithLocation({
    required String id,
    required String name,
    required int age,
    required String email,
    required double latitude,
    required double longitude,
  }) async {
    final supabase = Supabase.instance.client;
    await supabase.from('users').upsert({
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<void> createTestUsers() async {
    final supabase = Supabase.instance.client;
    final testUsers = [
      {
        'id': 'test1@example.com',
        'name': 'Test User 1',
        'age': 25,
        'email': 'test1@example.com',
        'photoUrl': '',
        'favoriteBeer': 'IPA',
        'bio': 'Just a test user',
        'lastCheckedInLocation': 'Test Bar',
        'lastCheckedInDistance': 1.2,
        'beerPreferences': ['IPA', 'Stout'],
        'latitude': 50.45,
        'longitude': 30.52,
      },
      {
        'id': 'test2@example.com',
        'name': 'Test User 2',
        'age': 30,
        'email': 'test2@example.com',
        'photoUrl': '',
        'favoriteBeer': 'Lager',
        'bio': 'Another test user',
        'lastCheckedInLocation': 'Sample Pub',
        'lastCheckedInDistance': 2.5,
        'beerPreferences': ['Lager', 'Pilsner'],
        'latitude': 50.46,
        'longitude': 30.53,
      },
    ];
    await supabase.from('users').upsert(testUsers);
  }

  Future<List<app_user.User>> getAllUsersRaw() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users').select();
    if (response.isNotEmpty) {
      return response
          .map(
            (item) => app_user.User(
              id: item['id']?.toString() ?? '',
              name: item['name'] ?? '',
              age: int.tryParse(item['age']?.toString() ?? '') ?? 0,
              photoUrl: item['photoUrl'] ?? '',
              favoriteBeer: item['favoriteBeer'] ?? '',
              bio: item['bio'],
              lastCheckedInLocation: item['lastCheckedInLocation'],
              lastCheckedInDistance: (item['lastCheckedInDistance'] is num)
                  ? (item['lastCheckedInDistance'] as num).toDouble()
                  : null,
              beerPreferences: (item['beerPreferences'] is List)
                  ? List<String>.from(item['beerPreferences'])
                  : [],
            ),
          )
          .toList();
    }
    return [];
  }
}
