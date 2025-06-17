import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/bar.dart';
import '../../domain/repositories/bar_repository.dart';
import '../datasources/mock_bar_data_source.dart';

/// Implementation of the BarRepository interface using mock data
class BarRepositoryImpl implements BarRepository {
  final MockBarDataSource _dataSource;

  BarRepositoryImpl({MockBarDataSource? dataSource})
      : _dataSource = dataSource ?? MockBarDataSource();

  @override
  Future<List<Bar>> getBars() async {
    // In a real app, we would filter based on user preferences and location
    return _dataSource.getBars();
  }

  @override
  Future<Bar?> getBarById(String barId) async {
    final bars = _dataSource.getBars();
    try {
      return bars.firstWhere((bar) => bar.id == barId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> likeBar(String barId) async {
    // In a real app, we would store this in a database
    final prefs = await SharedPreferences.getInstance();
    final likedBars = prefs.getStringList('liked_bars') ?? [];
    if (!likedBars.contains(barId)) {
      likedBars.add(barId);
      await prefs.setStringList('liked_bars', likedBars);
    }
  }

  @override
  Future<void> dislikeBar(String barId) async {
    // In a real app, we would store this in a database
    final prefs = await SharedPreferences.getInstance();
    final dislikedBars = prefs.getStringList('disliked_bars') ?? [];
    if (!dislikedBars.contains(barId)) {
      dislikedBars.add(barId);
      await prefs.setStringList('disliked_bars', dislikedBars);
    }
  }

  @override
  Future<void> checkIn(String barId) async {
    // In a real app, we would store this in a database with timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_checkin', barId);
    await prefs.setInt('last_checkin_time', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<Bar>> getBarsWithPlannedVisits() async {
    // In a real app, we would query a database for bars with planned visits
    // For now, we'll just return bars that have plannedVisitorsCount > 0
    final bars = _dataSource.getBars();
    return bars.where((bar) => bar.plannedVisitorsCount != null && bar.plannedVisitorsCount! > 0).toList();
  }
}
