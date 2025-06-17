import '../entities/user.dart';

/// Interface for user repository
abstract class UserRepository {
  /// Get a list of users for swiping
  Future<List<User>> getUsers();

  /// Like a user
  Future<void> likeUser(String userId);

  /// Dislike a user
  Future<void> dislikeUser(String userId);

  /// Get matches for the current user
  Future<List<String>> getMatches();
}
