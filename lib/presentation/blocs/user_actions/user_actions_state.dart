import 'package:equatable/equatable.dart';

abstract class UserActionState extends Equatable {
  const UserActionState();

  @override
  List<Object> get props => [];
}

class UserActionInitial extends UserActionState {}

class UserActionInProgress extends UserActionState {}

class UserActionSuccess extends UserActionState {
  final String message;

  const UserActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class UserActionFailure extends UserActionState {
  final String error;

  const UserActionFailure(this.error);

  @override
  List<Object> get props => [error];
}
