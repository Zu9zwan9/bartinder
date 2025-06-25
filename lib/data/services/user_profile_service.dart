import 'package:flutter/foundation.dart';
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
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile for $userId: $e');
      }
    }
    return null;
  }

  /// Updates the user's avatar_url field in the users table
  /// Returns true on success, false otherwise
  static Future<bool> updateAvatarUrl(String userId, String avatarUrl) async {
    try {
      if (kDebugMode) {
        print('Updating avatar URL for user $userId: $avatarUrl');
      }

      final result = await _supabase
          .from('users')
          .update({'avatar_url': avatarUrl})
          .eq('id', userId);

      if (kDebugMode) {
        print('Update result: $result');
      }

      // Supabase update returns an empty list on success, not null
      // Check if the operation completed without throwing an exception
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating avatar URL for user $userId: $e');
      }
      return false;
    }
  }
}
