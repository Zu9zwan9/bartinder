import '../entities/bar.dart';

/// Interface for bar repository
abstract class BarRepository {
  /// Get a list of bars for discovery
  Future<List<Bar>> getBars();

  /// Get a bar by ID
  Future<Bar?> getBarById(String barId);

  /// Like a bar
  Future<void> likeBar(String barId);

  /// Dislike a bar
  Future<void> dislikeBar(String barId);

  /// Check in to a bar
  Future<void> checkIn(String barId);

  /// Get bars with planned visits
  Future<List<Bar>> getBarsWithPlannedVisits();
}
