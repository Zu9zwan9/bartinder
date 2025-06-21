part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Position position;
  const LocationLoaded({required this.position});

  @override
  List<Object?> get props => [position];
}

class UsersNearbyLoaded extends LocationState {
  final List<Map<String, dynamic>> users;
  const UsersNearbyLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

