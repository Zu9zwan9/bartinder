import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Events for the UserSwipeBloc
abstract class UserSwipeEvent extends Equatable {
  const UserSwipeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load users for swiping
class LoadUsers extends UserSwipeEvent {
  const LoadUsers();
}

/// Event when a user is liked
class LikeUser extends UserSwipeEvent {
  final User user;

  const LikeUser(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event when a user is disliked
class DislikeUser extends UserSwipeEvent {
  final User user;

  const DislikeUser(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event when a match is created
class MatchCreated extends UserSwipeEvent {
  final User matchedUser;

  const MatchCreated(this.matchedUser);

  @override
  List<Object?> get props => [matchedUser];
}
