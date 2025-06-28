import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/bar.dart';

/// Production-ready data source for bars using Supabase database
class SupabaseBarDataSource {
  final SupabaseClient _supabase;
  List<Bar>? _cachedBars;

  SupabaseBarDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Returns a list of bars from the Supabase database
  Future<List<Bar>> getBars() async {
    // Возвращаем данные из кэша, если они доступны
    if (_cachedBars != null) {
      return _cachedBars!;
    }

    try {
      final response = await _supabase
          .from('bars')
          .select('*')
          .order('name');

      final List<dynamic> data = response as List<dynamic>;

      final List<Bar> bars = [];
      for (final item in data) {
        final bar = _parseBarFromSupabase(item);
        if (bar != null) {
          bars.add(bar);
        }
      }

      _cachedBars = bars;
      return bars;
    } catch (e) {
      throw Exception('Failed to load bars from Supabase: $e');
    }
  }

  /// Get a specific bar by ID
  Future<Bar?> getBarById(String barId) async {
    try {
      final response = await _supabase
          .from('bars')
          .select('*')
          .eq('id', barId)
          .single();

      return _parseBarFromSupabase(response);
    } catch (e) {
      return null;
    }
  }

  /// Get bars filtered by distance from user location
  Future<List<Bar>> getBarsWithinDistance({
    required double userLatitude,
    required double userLongitude,
    required double maxDistanceKm,
  }) async {
    final bars = await getBars();

    // Calculate distance for each bar and filter
    final List<Bar> filteredBars = [];

    for (final bar in bars) {
      final distance = _calculateDistance(
        userLatitude,
        userLongitude,
        bar.latitude,
        bar.longitude,
      );

      if (distance <= maxDistanceKm) {
        // Update bar with calculated distance
        final updatedBar = bar.copyWith(distance: distance);
        filteredBars.add(updatedBar);
      }
    }

    // Sort by distance (closest first)
    filteredBars.sort((a, b) => a.distance.compareTo(b.distance));

    return filteredBars;
  }

  /// Get bars with planned visits (users heading there)
  Future<List<Bar>> getBarsWithPlannedVisits() async {
    final bars = await getBars();
    return bars
        .where((bar) =>
    bar.plannedVisitorsCount != null &&
        bar.plannedVisitorsCount! > 0)
        .toList();
  }

  /// Parse a single bar from Supabase data
  Bar? _parseBarFromSupabase(Map<String, dynamic> json) {
    try {
      final id = json['id']?.toString();
      final name = json['name'] as String?;

      if (id == null || name == null) {
        return null;
      }

      // Extract coordinates
      double? latitude = (json['latitude'] as num?)?.toDouble();
      double? longitude = (json['longitude'] as num?)?.toDouble();

      // Skip bars without valid coordinates
      if (latitude == null || longitude == null) {
        return null;
      }

      // Build address from available fields
      final street = json['street'] as String?;
      final city = json['city'] as String?;
      final country = json['country'] as String?;

      String address = '';
      if (street != null && street.isNotEmpty) {
        address = street;
      }
      if (city != null && city.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += city;
      }
      if (country != null && country.isNotEmpty) {
        if (address.isNotEmpty) address += ', ';
        address += country;
      }

      // If no address components, use city or country
      if (address.isEmpty) {
        address = city ?? country ?? 'Unknown Location';
      }

      // Extract images
      final images = json['images'] as List<dynamic>?;
      String? photoUrl;
      if (images != null && images.isNotEmpty) {
        photoUrl = images.first as String?;
      }

      // Extract other fields
      final rating = (json['rating'] as num?)?.toDouble();
      final partner = json['partner'] as bool? ?? false;
      final discount = (json['discount'] as num?)?.toInt() ?? 0;

      // Generate description based on available data
      String description = json['description'] as String? ?? 'A great place to enjoy drinks';
      if (rating != null && description == 'A great place to enjoy drinks') {
        description += ' with a ${rating.toStringAsFixed(1)} star rating';
      }
      if (partner && discount > 0) {
        description += '. Partner location with $discount% discount for app users';
      } else if (partner) {
        description += '. Partner location with special offers';
      }
      if (description == 'A great place to enjoy drinks') {
        description += '.';
      }

      // Extract beer types from database or generate based on bar name
      List<String> beerTypes = [];
      if (json['beer_types'] != null) {
        beerTypes = List<String>.from(json['beer_types'] as List);
      } else {
        beerTypes = _generateBeerTypesForBar(name);
      }

      return Bar(
        id: id,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        distance: 0.0, // Will be calculated dynamically
        photoUrl: photoUrl,
        description: description,
        beerTypes: beerTypes,
        hasDiscount: partner && discount > 0,
        discountPercentage: discount > 0 ? discount : null,
        plannedVisitorsCount: (json['planned_visitors_count'] as num?)?.toInt() ?? _generatePlannedVisitors(),
        crowdLevel: _normalizeCrowdLevel(json['crowd_level']?.toString()) ?? _generateCrowdLevel(),
        usersHeadingThere: [],
        events: [], // In a real app, this would come from events table
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing bar from Supabase: $e');
      }
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  double _calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    // Using Haversine formula for accurate distance calculation
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(endLatitude - startLatitude);
    final double dLon = _degreesToRadians(endLongitude - startLongitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.cos(startLatitude.toRadians()) *
                math.cos(endLatitude.toRadians()) *
                math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Generate beer types based on bar name (fallback solution)
  List<String> _generateBeerTypesForBar(String barName) {
    final name = barName.toLowerCase();

    if (name.contains('craft') || name.contains('brewery')) {
      return ['IPA', 'Stout', 'Pale Ale', 'Porter'];
    } else if (name.contains('german') || name.contains('bier')) {
      return ['Pilsner', 'Hefeweizen', 'Dunkel', 'Bock'];
    } else if (name.contains('pub')) {
      return ['Lager', 'Bitter', 'Mild', 'Stout'];
    } else {
      return ['Lager', 'IPA', 'Stout'];
    }
  }

  /// Generate random planned visitors count (fallback)
  int _generatePlannedVisitors() {
    return [0, 1, 2, 3, 5, 8, 12][DateTime.now().millisecond % 7];
  }

  /// Generate random crowd level (fallback)
  String _generateCrowdLevel() {
    final levels = ['Low', 'Medium', 'High'];
    return levels[DateTime.now().millisecond % 3];
  }

  /// Normalize crowd level to standard values
  String? _normalizeCrowdLevel(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    if (normalized == 'low') return 'Low';
    if (normalized == 'medium' || normalized == 'moderate') return 'Medium';
    if (normalized == 'high' || normalized == 'busy') return 'High';
    return null;
  }

  /// Clear cached data to force refresh
  void clearCache() {
    _cachedBars = null;
  }
}

/// Extension to add toRadians method to double
extension DoubleExtension on double {
  double toRadians() => this * (math.pi / 180);
}
