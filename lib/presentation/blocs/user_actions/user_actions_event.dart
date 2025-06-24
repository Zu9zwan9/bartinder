import 'package:equatable/equatable.dart';



abstract class UserActionEvent extends Equatable {
  const UserActionEvent();

  @override
  List<Object> get props => [];
}

class LikeUserEvent extends UserActionEvent {
  final String userId;

  const LikeUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class DislikeUserEvent extends UserActionEvent {
  final String userId;

  const DislikeUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

