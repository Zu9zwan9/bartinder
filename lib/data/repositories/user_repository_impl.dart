import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_user_data_source.dart';

/// Implementation of the UserRepository interface using mock data
class UserRepositoryImpl implements UserRepository {
  final MockUserDataSource _dataSource;

  UserRepositoryImpl({MockUserDataSource? dataSource})
      : _dataSource = dataSource ?? MockUserDataSource();

  @override
  Future<List<User>> getUsers() async {
    // TODO In a real app, we would filter out users that have already been liked or disliked
    return _dataSource.getUsers();
  }

  @override
  Future<void> likeUser(String userId) async {
    // TODO In a real app, we would store this in a database
    final prefs = await SharedPreferences.getInstance();
    final likedUsers = prefs.getStringList('liked_users') ?? [];
    if (!likedUsers.contains(userId)) {
      likedUsers.add(userId);
      await prefs.setStringList('liked_users', likedUsers);
    }
  }

  @override
  Future<void> dislikeUser(String userId) async {
    // TODO In a real app, we would store this in a database
    final prefs = await SharedPreferences.getInstance();
    final dislikedUsers = prefs.getStringList('disliked_users') ?? [];
    if (!dislikedUsers.contains(userId)) {
      dislikedUsers.add(userId);
      await prefs.setStringList('disliked_users', dislikedUsers);
    }
  }

  @override
  Future<List<String>> getMatches() async {
    // TODO In a real app, we would check if users we liked also liked us
    // For now, we'll just return a subset of the liked users as "matches"
    final prefs = await SharedPreferences.getInstance();
    final likedUsers = prefs.getStringList('liked_users') ?? [];

    // Simulate that some of the liked users also liked us back
    return likedUsers.take(likedUsers.length ~/ 2).toList();
  }
}
