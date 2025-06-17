import 'package:equatable/equatable.dart';

/// Base class for all matches events
abstract class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load potential matches
class LoadPotentialMatches extends MatchesEvent {
  const LoadPotentialMatches();
}

/// Event to refresh potential matches
class RefreshPotentialMatches extends MatchesEvent {
  const RefreshPotentialMatches();
}

/// Event to like a user
class LikeUser extends MatchesEvent {
  final String userId;

  const LikeUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to dislike a user
class DislikeUser extends MatchesEvent {
  final String userId;

  const DislikeUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load matches
class LoadMatches extends MatchesEvent {
  const LoadMatches();
}

/// Event to send a message to a match
class SendMessage extends MatchesEvent {
  final String userId;
  final String message;

  const SendMessage(this.userId, this.message);

  @override
  List<Object?> get props => [userId, message];
}

/// Event to invite a match to a bar
class InviteToBar extends MatchesEvent {
  final String userId;
  final String barId;

  const InviteToBar(this.userId, this.barId);

  @override
  List<Object?> get props => [userId, barId];
}
