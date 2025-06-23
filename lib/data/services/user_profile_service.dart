import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to fetch and update user profiles
class UserProfileService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches the user profile by user ID and returns a map of profile fields
  /// Returns null if no profile found or on error
  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('avatar_url, email, name')
          .eq('id', userId)
          .single();
      if (response != null && response is Map<String, dynamic>) {
        return response;
      }
    } catch (_) {}
    return null;
  }

  /// Updates the user's avatar_url field in the users table
  /// Returns true on success, false otherwise
  static Future<bool> updateAvatarUrl(String userId, String avatarUrl) async {
    try {
      final result = await _supabase
          .from('users')
          .update({'avatar_url': avatarUrl})
          .eq('id', userId);
      return (result != null);
    } catch (_) {
      return false;
    }
  }
}
