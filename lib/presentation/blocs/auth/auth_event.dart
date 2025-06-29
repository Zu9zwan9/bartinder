import 'package:equatable/equatable.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status
class AuthStatusRequested extends AuthEvent {
  const AuthStatusRequested();
}

/// Event to sign up with email and password
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final int age;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
  });

  @override
  List<Object?> get props => [email, password, name, age];
}

/// Event to sign in with email and password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign in with Apple
class AuthAppleSignInRequested extends AuthEvent {
  const AuthAppleSignInRequested();
}

/// Event to sign in with Google
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Event to sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event to reset password
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to update password
class AuthPasswordUpdateRequested extends AuthEvent {
  final String newPassword;

  const AuthPasswordUpdateRequested({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

/// Event when auth state changes externally
class AuthStateChanged extends AuthEvent {
  final String? userId;

  const AuthStateChanged({this.userId});

  @override
  List<Object?> get props => [userId];
}
