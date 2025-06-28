import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../data/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state and operations
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late StreamSubscription _authStateSubscription;

  AuthBloc() : super(const AuthInitial()) {
    // Initialize auth service
    AuthService.initialize();

    // Listen to auth state changes
    _authStateSubscription = AuthService.authStateChanges.listen((user) {
      add(AuthStateChanged(userId: user?.id));
    });

    // Register event handlers
    on<AuthStatusRequested>(_onAuthStatusRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthAppleSignInRequested>(_onAuthAppleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthPasswordUpdateRequested>(_onAuthPasswordUpdateRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Check initial auth status
    add(const AuthStatusRequested());
  }

  /// Handle auth status check
  Future<void> _onAuthStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle sign up request
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(operation: 'Signing up...'));

    try {
      final result = await AuthService.signUp(
        email: event.email,
        password: event.password,
        metadata: {'name': event.name, 'age': event.age},
      );

      if (result.isSuccess && result.data != null) {
        // Check if email verification is required
        if (result.data!.emailConfirmedAt == null) {
          emit(AuthEmailVerificationRequired(email: event.email));
        } else {
          emit(AuthAuthenticated(user: result.data!));
        }
      } else {
        emit(
          AuthFailure(
            error: result.error?.message ?? 'Sign up failed',
            code: result.error?.code,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      emit(
        AuthFailure(
          error: 'An unexpected error occurred during sign up',
          code: 'unknown_error',
        ),
      );
    }
  }

  /// Handle sign in request
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(operation: 'Signing in...'));

    try {
      final result = await AuthService.signIn(
        email: event.email,
        password: event.password,
      );

      if (result.isSuccess && result.data != null) {
        emit(AuthAuthenticated(user: result.data!));
      } else {
        emit(
          AuthFailure(
            error: result.error?.message ?? 'Sign in failed',
            code: result.error?.code,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      emit(
        AuthFailure(
          error: 'An unexpected error occurred during sign in',
          code: 'unknown_error',
        ),
      );
    }
  }

  /// Handle Apple Sign In request
  Future<void> _onAuthAppleSignInRequested(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(operation: 'Signing in with Apple...'));

    try {
      final result = await AuthService.signInWithApple();

      if (result.isSuccess && result.data != null) {
        emit(AuthAuthenticated(user: result.data!));
      } else {
        emit(
          AuthFailure(
            error: result.error?.message ?? 'Apple Sign In failed',
            code: result.error?.code,
          ),
        );
      }
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        emit(
          AuthFailure(
            error: 'Apple authorization failed: ${e.message}',
            code: e.code.toString(),
          ),
        );
      } else {
        if (kDebugMode) {
          print('Apple Sign In error: $e');
        }
        emit(
          AuthFailure(
            error: 'An unexpected error occurred during Apple Sign In',
            code: 'unknown_error',
          ),
        );
      }
    }
  }

  /// Handle sign out request
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(operation: 'Signing out...'));

    try {
      final result = await AuthService.signOut();

      if (result.isSuccess) {
        emit(const AuthUnauthenticated());
      } else {
        emit(
          AuthFailure(
            error: result.error?.message ?? 'Sign out failed',
            code: result.error?.code,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      emit(
        AuthFailure(
          error: 'An unexpected error occurred during sign out',
          code: 'unknown_error',
        ),
      );
    }
  }

  /// Handle password reset request
  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(operation: 'Sending password reset email...'));

    try {
      final result = await AuthService.resetPassword(email: event.email);

      if (result.isSuccess) {
        emit(AuthPasswordResetSent(email: event.email));
      } else {
        emit(
          AuthFailure(
            error: result.error?.message ?? 'Password reset failed',
            code: result.error?.code,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Password reset error: $e');
      }
      emit(
        AuthFailure(
          error: 'An unexpected error occurred during password reset',
          code: 'unknown_error',
        ),
      );
    }
  }

  /// Handle password update request
  Future<void> _onAuthPasswordUpdateRequested(
    AuthPasswordUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInProgress(operation: 'Updating password...'));

    try {
      final result = await AuthService.updatePassword(
        newPassword: event.newPassword,
      );

      if (result.isSuccess && result.data != null) {
        emit(
          AuthSuccess(
            message: 'Password updated successfully',
            user: result.data,
          ),
        );
      } else {
        emit(
          AuthFailure(
            error: result.error?.message ?? 'Password update failed',
            code: result.error?.code,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Password update error: $e');
      }
      emit(
        AuthFailure(
          error: 'An unexpected error occurred during password update',
          code: 'unknown_error',
        ),
      );
    }
  }

  /// Handle external auth state changes
  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    final user = AuthService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    AuthService.dispose();
    return super.close();
  }
}
