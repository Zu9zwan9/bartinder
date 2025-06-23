import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when authentication status is unknown
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when checking authentication status
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({
    required this.user,
  });

  @override
  List<Object?> get props => [user.id];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when authentication operation is in progress
class AuthInProgress extends AuthState {
  final String operation;

  const AuthInProgress({
    required this.operation,
  });

  @override
  List<Object?> get props => [operation];
}

/// State when authentication operation succeeds
class AuthSuccess extends AuthState {
  final String message;
  final User? user;

  const AuthSuccess({
    required this.message,
    this.user,
  });

  @override
  List<Object?> get props => [message, user?.id];
}

/// State when authentication operation fails
class AuthFailure extends AuthState {
  final String error;
  final String? code;

  const AuthFailure({
    required this.error,
    this.code,
  });

  @override
  List<Object?> get props => [error, code];
}

/// State when password reset email is sent
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// State when user needs to verify email
class AuthEmailVerificationRequired extends AuthState {
  final String email;

  const AuthEmailVerificationRequired({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}
