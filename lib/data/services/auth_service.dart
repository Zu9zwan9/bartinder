import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'storage_service.dart';

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({required this.code, required this.message});

  @override
  String toString() => 'AuthException: $code - $message';
}

/// Result wrapper for authentication operations
class AuthResult<T> {
  final T? data;
  final AuthException? error;
  final bool isSuccess;

  const AuthResult._({this.data, this.error, required this.isSuccess});

  factory AuthResult.success(T data) =>
      AuthResult._(data: data, isSuccess: true);

  factory AuthResult.failure(AuthException error) =>
      AuthResult._(error: error, isSuccess: false);
}

/// Supabase authentication service
class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Stream controller for auth state changes
  static final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _authStateController.stream;

  /// Current authenticated user
  static User? get currentUser => _supabase.auth.currentUser;

  /// Current user ID
  static String? get currentUserId => currentUser?.id;

  /// Initialize auth service and listen to auth state changes
  static void initialize() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      _authStateController.add(user);
      if (kDebugMode) {
        print('Auth state changed: ${user?.id ?? 'null'}');
      }
    });
  }

  /// Generate a random avatar URL from DiceBear API
  static String generateRandomAvatar() {
    final random = Random();
    final seed = random.nextInt(1000000); // Generate random seed
    return 'https://api.dicebear.com/6.x/notionists/svg?seed=$seed';
  }

  /// Update user avatar URL
  static Future<AuthResult<User>> updateAvatar(String avatarUrl) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure(
          const AuthException(
            code: 'not_authenticated',
            message: 'User not authenticated',
          ),
        );
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: {...?user.userMetadata, 'avatar_url': avatarUrl}),
      );

      if (response.user != null) {
        // Persist avatar_url in users table
        await _supabase
            .from('users')
            .update({'avatar_url': avatarUrl})
            .eq('id', user.id);
        if (kDebugMode) {
          print('Avatar updated successfully: $avatarUrl');
        }
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthException(
            code: 'update_failed',
            message: 'Failed to update avatar',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Avatar update error: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'unknown_error',
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  /// Generate a random avatar, upload to storage, and update user
  static Future<AuthResult<User>> uploadRandomAvatar() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure(
          const AuthException(
            code: 'not_authenticated',
            message: 'User not authenticated',
          ),
        );
      }
      // Generate external avatar URL
      final externalUrl = generateRandomAvatar();
      // Define storage path
      final path =
          'images/${user.id}/${DateTime.now().millisecondsSinceEpoch}.svg';
      // Upload and get signed URL
      final storageUrl = await StorageService.uploadFromUrl(externalUrl, path);
      // Update avatar metadata and users table
      return await updateAvatar(storageUrl);
    } catch (e) {
      if (kDebugMode) {
        print('uploadRandomAvatar error: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'avatar_upload_failed',
          message: 'Failed to upload and set avatar: $e',
        ),
      );
    }
  }

  /// Sign up with email and password
  static Future<AuthResult<User>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting sign up for email: $email');
      }

      // Generate random avatar and add to metadata
      final avatarUrl = generateRandomAvatar();
      final enrichedMetadata = {...?metadata, 'avatar_url': avatarUrl};

      if (kDebugMode) {
        print('Generated avatar URL: $avatarUrl');
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: enrichedMetadata,
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('Sign up successful: ${response.user!.id}');
        }
        // Ensure user exists in 'users' table for FK constraints
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'email': response.user!.email,
          'name':
              enrichedMetadata['name'] ??
              response.user!.email?.split('@').first,
          'password_hash': '',
          'avatar_url': avatarUrl,
        });
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthException(
            code: 'signup_failed',
            message: 'Sign up failed: No user returned',
          ),
        );
      }
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Sign up failed: $e');
      }
      return AuthResult.failure(e);
    } catch (e) {
      if (kDebugMode) {
        print('Sign up failed with unexpected error: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'unknown_error',
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  /// Sign in with email and password
  static Future<AuthResult<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting sign in for email: $email');
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('Sign in successful: ${response.user!.id}');
        }
        // Ensure user exists in 'users' table
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'email': response.user!.email,
          'name':
              (response.user!.userMetadata?['name'] as String?) ??
              response.user!.email!.split('@').first,
          'password_hash': '',
          'avatar_url':
              response.user!.userMetadata?['avatar_url'] as String? ?? '',
        });
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthException(
            code: 'signin_failed',
            message: 'Sign in failed: No user returned',
          ),
        );
      }
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Sign in failed: $e');
      }
      return AuthResult.failure(e);
    } catch (e) {
      if (kDebugMode) {
        print('Sign in failed with unexpected error: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'unknown_error',
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  /// Sign out current user
  static Future<AuthResult<void>> signOut() async {
    try {
      if (kDebugMode) {
        print('Attempting sign out');
      }

      await _supabase.auth.signOut();

      if (kDebugMode) {
        print('Sign out successful');
      }
      return AuthResult.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Sign out failed: $e');
      }
      return AuthResult.failure(
        AuthException(code: 'signout_failed', message: 'Sign out failed: $e'),
      );
    }
  }

  /// Sign in with Apple (supports both iOS native and web OAuth)
  static Future<AuthResult<User>> signInWithApple() async {
    try {
      if (kDebugMode) {
        print('Attempting Apple Sign In');
      }

      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        return AuthResult.failure(
          const AuthException(
            code: 'apple_signin_unavailable',
            message: 'Apple Sign In is not available on this device',
          ),
        );
      }

      // Get Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.7wells.sipswipe',
          redirectUri: Uri.parse('https://rzsxqtmbgppentouocpi.supabase.co/auth/v1/callback'),
        ),
      );

      if (kDebugMode) {
        print('Apple ID credential obtained: ${credential.userIdentifier}');
      }

      // Create JWT token for Supabase
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: credential.state,
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('Apple Sign In successful: ${response.user!.id}');
        }

        // Extract user information from Apple credential
        final fullName = credential.givenName != null && credential.familyName != null
            ? '${credential.givenName} ${credential.familyName}'
            : null;

        final avatarUrl = generateRandomAvatar();

        // Ensure user exists in 'users' table
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'email': credential.email ?? response.user!.email,
          'name': fullName ??
                  credential.email?.split('@').first ??
                  response.user!.email?.split('@').first ??
                  'Apple User',
          'password_hash': '',
          'avatar_url': avatarUrl,
          'provider': 'apple',
        });

        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthException(
            code: 'apple_signin_failed',
            message: 'Apple Sign In failed: No user returned',
          ),
        );
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (kDebugMode) {
        print('Apple Sign In authorization failed: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'apple_authorization_failed',
          message: 'Apple authorization failed: ${e.message}',
        ),
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Apple Sign In failed: $e');
      }
      return AuthResult.failure(e);
    } catch (e) {
      if (kDebugMode) {
        print('Apple Sign In failed with unexpected error: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'unknown_error',
          message: 'An unexpected error occurred during Apple Sign In: $e',
        ),
      );
    }
  }

  /// Reset password for email
  static Future<AuthResult<void>> resetPassword({required String email}) async {
    try {
      if (kDebugMode) {
        print('Attempting password reset for email: $email');
      }

      await _supabase.auth.resetPasswordForEmail(email);

      if (kDebugMode) {
        print('Password reset email sent successfully');
      }
      return AuthResult.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Password reset failed: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'password_reset_failed',
          message: 'Password reset failed: $e',
        ),
      );
    }
  }

  /// Update user password
  static Future<AuthResult<User>> updatePassword({
    required String newPassword,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting password update');
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('Password update successful');
        }
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthException(
            code: 'password_update_failed',
            message: 'Password update failed: No user returned',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Password update failed: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'password_update_failed',
          message: 'Password update failed: $e',
        ),
      );
    }
  }

  /// Update user metadata
  static Future<AuthResult<User>> updateUserMetadata({
    required Map<String, dynamic> metadata,
  }) async {
    try {
      if (kDebugMode) {
        print('Attempting user metadata update');
      }

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );

      if (response.user != null) {
        if (kDebugMode) {
          print('User metadata update successful');
        }
        return AuthResult.success(response.user!);
      } else {
        return AuthResult.failure(
          const AuthException(
            code: 'metadata_update_failed',
            message: 'Metadata update failed: No user returned',
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('User metadata update failed: $e');
      }
      return AuthResult.failure(
        AuthException(
          code: 'metadata_update_failed',
          message: 'Metadata update failed: $e',
        ),
      );
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current session
  static Session? get currentSession => _supabase.auth.currentSession;

  /// Dispose resources
  static void dispose() {
    _authStateController.close();
  }
}
