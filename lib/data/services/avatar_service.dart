import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';
import 'user_profile_service.dart';

/// Production-ready avatar service following Apple HIG and security best practices
class AvatarService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Base URL for Dicebear API
  static const String _dicebearBaseUrl = 'https://api.dicebear.com/6.x/notionists/svg';

  /// Generate a unique seed for avatar generation
  static String _generateSeed(String userId) {
    final random = Random(userId.hashCode);
    return '${userId.substring(0, 8)}_${random.nextInt(999999)}';
  }

  /// Generate avatar URL from Dicebear API
  static String generateAvatarUrl(String seed) {
    return '$_dicebearBaseUrl?seed=$seed&backgroundColor=transparent&size=200';
  }

  /// Generate and store user avatar
  /// Returns the stored avatar URL or null if failed
  static Future<String?> generateAndStoreAvatar(String userId) async {
    try {
      // Generate unique seed for this user
      final seed = _generateSeed(userId);

      // Generate avatar URL
      final avatarUrl = generateAvatarUrl(seed);

      // Create storage path: images/{userId}/avatar.svg
      final storagePath = 'images/$userId/avatar.svg';

      // Delete old avatar if exists
      final profile = await UserProfileService.fetchUserProfile(userId);
      final oldUrl = profile?['avatar_url'] as String?;
      if (oldUrl != null && oldUrl.isNotEmpty) {
        final oldPath = StorageService.getPathFromUrl(oldUrl);
        if (oldPath != null) {
          await StorageService.deleteFile(oldPath); // Delete the old avatar
        }
      }

      if (kDebugMode) {
        print('Generating avatar for user $userId with seed: $seed');
        print('Avatar URL: $avatarUrl');
        print('Storage path: $storagePath');
      }

      // Download and store avatar
      final storedUrl = await StorageService.uploadFromUrl(avatarUrl, storagePath);

      // Update user profile with stored avatar URL
      final updateSuccess = await UserProfileService.updateAvatarUrl(userId, storedUrl);

      if (updateSuccess) {
        if (kDebugMode) {
          print('Avatar successfully stored and profile updated: $storedUrl');
        }
        return storedUrl;
      } else {
        if (kDebugMode) {
          print('Failed to update user profile with avatar URL');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating and storing avatar: $e');
      }
      return null;
    }
  }

  /// Regenerate avatar for user (creates new avatar with different seed)
  static Future<String?> regenerateAvatar(String userId) async {
    try {
      // Generate new random seed
      final random = Random();
      final newSeed = '${userId.substring(0, 8)}_${random.nextInt(999999)}_${DateTime.now().millisecondsSinceEpoch}';

      // Generate new avatar URL
      final avatarUrl = generateAvatarUrl(newSeed);

      // Create storage path with timestamp to avoid caching issues
      final storagePath = 'images/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.svg';

      // Delete old avatar if exists
      final profile = await UserProfileService.fetchUserProfile(userId);
      final oldUrl = profile?['avatar_url'] as String?;
      if (oldUrl != null && oldUrl.isNotEmpty) {
        final oldPath = StorageService.getPathFromUrl(oldUrl);
        if (oldPath != null) {
          await StorageService.deleteFile(oldPath); // Delete the old avatar
        }
      }

      if (kDebugMode) {
        print('Regenerating avatar for user $userId with new seed: $newSeed');
      }

      // Download and store new avatar
      final storedUrl = await StorageService.uploadFromUrl(avatarUrl, storagePath);

      // Update user profile with new avatar URL
      final updateSuccess = await UserProfileService.updateAvatarUrl(userId, storedUrl);

      if (updateSuccess) {
        if (kDebugMode) {
          print('Avatar successfully regenerated and profile updated: $storedUrl');
        }
        return storedUrl;
      } else {
        if (kDebugMode) {
          print('Failed to update user profile with new avatar URL');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error regenerating avatar: $e');
      }
      return null;
    }
  }

  /// Get current user's avatar URL from database
  static Future<String?> getCurrentUserAvatarUrl() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final profile = await UserProfileService.fetchUserProfile(userId);
      return profile?['avatar_url'] as String?;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching current user avatar: $e');
      }
      return null;
    }
  }

  /// Check if user has an avatar
  static Future<bool> hasAvatar(String userId) async {
    try {
      final profile = await UserProfileService.fetchUserProfile(userId);
      final avatarUrl = profile?['avatar_url'] as String?;
      return avatarUrl != null && avatarUrl.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if user has avatar: $e');
      }
      return false;
    }
  }

  /// Initialize avatar for new user if they don't have one
  static Future<String?> initializeUserAvatar(String userId) async {
    try {
      final hasExistingAvatar = await hasAvatar(userId);
      if (hasExistingAvatar) {
        // User already has an avatar, return existing one
        final profile = await UserProfileService.fetchUserProfile(userId);
        return profile?['avatar_url'] as String?;
      }

      // Generate new avatar for user
      return await generateAndStoreAvatar(userId);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing user avatar: $e');
      }
      return null;
    }
  }

  /// Upload a custom avatar file for a user, deleting any existing avatar
  static Future<String?> uploadCustomAvatar(String userId, File file) async {
    try {
      // Delete old avatar if exists
      final profile = await UserProfileService.fetchUserProfile(userId);
      final oldUrl = profile?['avatar_url'] as String?;
      if (oldUrl != null && oldUrl.isNotEmpty) {
        final oldPath = StorageService.getPathFromUrl(oldUrl);
        if (oldPath != null) {
          await StorageService.deleteFile(oldPath); // Delete the old avatar
        }
      }

      // Prepare storage path with timestamp and original extension
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = p.extension(file.path).replaceFirst('.', '');
      final storagePath = 'images/$userId/avatar_$timestamp.$ext';

      // Upload file
      final storedUrl = await StorageService.uploadFile(file, storagePath);

      // Update user profile
      final success = await UserProfileService.updateAvatarUrl(userId, storedUrl);
      return success ? storedUrl : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading custom avatar: $e');
      }
      return null;
    }
  }
}
