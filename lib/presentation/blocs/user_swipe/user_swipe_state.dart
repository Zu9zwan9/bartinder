import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// States for the UserSwipeBloc
abstract class UserSwipeState extends Equatable {
  const UserSwipeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class UserSwipeInitial extends UserSwipeState {
  const UserSwipeInitial();
}

/// State when users are being loaded
class UserSwipeLoading extends UserSwipeState {
  const UserSwipeLoading();
}

/// State when users have been loaded successfully
class UserSwipeLoaded extends UserSwipeState {
  final List<User> users;
  final List<String> matches;

  const UserSwipeLoaded({required this.users, this.matches = const []});

  @override
  List<Object?> get props => [users, matches];

  /// Create a copy of this state with the given fields replaced
  UserSwipeLoaded copyWith({List<User>? users, List<String>? matches}) {
    return UserSwipeLoaded(
      users: users ?? this.users,
      matches: matches ?? this.matches,
    );
  }
}

/// State when a match has been created
class UserSwipeMatch extends UserSwipeState {
  final User matchedUser;

  const UserSwipeMatch(this.matchedUser);

  @override
  List<Object?> get props => [matchedUser];
}

/// State when an error occurs
class UserSwipeError extends UserSwipeState {
  final String message;

  const UserSwipeError(this.message);

  @override
  List<Object?> get props => [message];
}
