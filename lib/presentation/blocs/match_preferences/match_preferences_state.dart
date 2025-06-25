part of 'match_preferences_bloc.dart';

abstract class MatchPreferencesState extends Equatable {
  const MatchPreferencesState();

  @override
  List<Object?> get props => [];
}

class MatchPreferencesInitial extends MatchPreferencesState {}

class MatchPreferencesLoading extends MatchPreferencesState {}

class MatchPreferencesLoaded extends MatchPreferencesState {
  final MatchPreferences preferences;

  const MatchPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class MatchPreferencesError extends MatchPreferencesState {
  final String message;

  const MatchPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}
