import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

/// Base class for all matches states
abstract class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

/// Loading potential matches state
class PotentialMatchesLoading extends MatchesState {
  const PotentialMatchesLoading();
}

/// Loaded potential matches state
class PotentialMatchesLoaded extends MatchesState {
  final List<User> users;

  const PotentialMatchesLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

/// Loading matches state
class MatchesLoading extends MatchesState {
  const MatchesLoading();
}

/// Loaded matches state
class MatchesLoaded extends MatchesState {
  final List<User> matches;

  const MatchesLoaded(this.matches);

  @override
  List<Object?> get props => [matches];
}

/// Match found state
class MatchFound extends MatchesState {
  final User matchedUser;

  const MatchFound(this.matchedUser);

  @override
  List<Object?> get props => [matchedUser];
}

/// Message sent state
class MessageSent extends MatchesState {
  final String userId;
  final String message;

  const MessageSent(this.userId, this.message);

  @override
  List<Object?> get props => [userId, message];
}

/// Invite sent state
class InviteSent extends MatchesState {
  final String userId;
  final String barId;
  final String barName;

  const InviteSent(this.userId, this.barId, this.barName);

  @override
  List<Object?> get props => [userId, barId, barName];
}

/// Error state
class MatchesError extends MatchesState {
  final String message;

  const MatchesError(this.message);

  @override
  List<Object?> get props => [message];
}
