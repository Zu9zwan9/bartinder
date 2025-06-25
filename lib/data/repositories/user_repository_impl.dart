import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user.dart' as app_user;
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_user_data_source.dart';

/// Implementation of the UserRepository interface using mock data
class UserRepositoryImpl implements UserRepository {
  final MockUserDataSource _dataSource;

  UserRepositoryImpl({MockUserDataSource? dataSource})
    : _dataSource = dataSource ?? MockUserDataSource();

  @override
  Future<List<app_user.User>> getUsers() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('users').select().limit(100);
    List data = [];
    data = response;
    if (data.isNotEmpty) {
      final users = data
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
      return users;
    }
    return _dataSource.getUsers();
  }

  @override
  Future<void> likeUser(String userId) async {
    // todo In a real app, we would store this in a database
    final prefs = await SharedPreferences.getInstance();
    final likedUsers = prefs.getStringList('liked_users') ?? [];
    if (!likedUsers.contains(userId)) {
      likedUsers.add(userId);
      await prefs.setStringList('liked_users', likedUsers);
    }
  }

  @override
  Future<void> dislikeUser(String userId) async {
    // todo In a real app, we would store this in a database
    final prefs = await SharedPreferences.getInstance();
    final dislikedUsers = prefs.getStringList('disliked_users') ?? [];
    if (!dislikedUsers.contains(userId)) {
      dislikedUsers.add(userId);
      await prefs.setStringList('disliked_users', dislikedUsers);
    }
  }

  @override
  Future<List<String>> getMatches() async {
    // todo In a real app, we would check if users we liked also liked us
    // For now, we'll just return a subset of the liked users as "matches"
    final prefs = await SharedPreferences.getInstance();
    final likedUsers = prefs.getStringList('liked_users') ?? [];

    // Simulate that some of the liked users also liked us back
    return likedUsers.take(likedUsers.length ~/ 2).toList();
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
