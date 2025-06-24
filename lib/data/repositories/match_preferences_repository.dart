import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/match_preferences.dart';

class MatchPreferencesRepository {
  final SupabaseClient supabase;

  MatchPreferencesRepository({SupabaseClient? supabase})
      : supabase = supabase ?? Supabase.instance.client;

  /// Get user's match preferences
  Future<MatchPreferences?> getMatchPreferences(String userId) async {
    try {
      final response = await supabase
          .from('match_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      return MatchPreferences(
        userId: response['user_id'],
        maxDistanceKm: response['max_distance_km'] ?? 25,
        ageRange: List<int>.from(response['age_range'] ?? [18, 65]),
        showMeInCityOnly: response['show_me_in_city_only'] ?? false,
        genderPreference: List<String>.from(response['gender_preference'] ?? []),
        beerTypes: List<String>.from(response['beer_types'] ?? []),
      );
    } catch (e) {
      // Return default preferences if none exist
      return MatchPreferences(
        userId: userId,
        maxDistanceKm: 25,
        ageRange: const [18, 65],
        showMeInCityOnly: false,
        genderPreference: const [],
        beerTypes: const [],
      );
    }
  }

  /// Save or update user's match preferences
  Future<void> saveMatchPreferences(MatchPreferences preferences) async {
    await supabase.from('match_preferences').upsert({
      'user_id': preferences.userId,
      'max_distance_km': preferences.maxDistanceKm,
      'age_range': preferences.ageRange,
      'show_me_in_city_only': preferences.showMeInCityOnly,
      'gender_preference': preferences.genderPreference,
      'beer_types': preferences.beerTypes,
    });
  }

  /// Update only the distance preference
  Future<void> updateMaxDistance(String userId, int maxDistanceKm) async {
    await supabase
        .from('match_preferences')
        .upsert({
          'user_id': userId,
          'max_distance_km': maxDistanceKm,
        });
  }

  /// Update age range preference
  Future<void> updateAgeRange(String userId, List<int> ageRange) async {
    await supabase
        .from('match_preferences')
        .upsert({
          'user_id': userId,
          'age_range': ageRange,
        });
  }

  /// Update gender preferences
  Future<void> updateGenderPreference(String userId, List<String> genderPreference) async {
    await supabase
        .from('match_preferences')
        .upsert({
          'user_id': userId,
          'gender_preference': genderPreference,
        });
  }

  /// Update beer type preferences
  Future<void> updateBeerTypes(String userId, List<String> beerTypes) async {
    await supabase
        .from('match_preferences')
        .upsert({
          'user_id': userId,
          'beer_types': beerTypes,
        });
  }
}
