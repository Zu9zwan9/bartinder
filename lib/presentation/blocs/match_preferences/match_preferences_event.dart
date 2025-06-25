part of 'match_preferences_bloc.dart';

abstract class MatchPreferencesEvent extends Equatable {
  const MatchPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatchPreferences extends MatchPreferencesEvent {}

class UpdateMaxDistance extends MatchPreferencesEvent {
  final int maxDistance;

  const UpdateMaxDistance(this.maxDistance);

  @override
  List<Object?> get props => [maxDistance];
}

class UpdateAgeRange extends MatchPreferencesEvent {
  final List<int> ageRange;

  const UpdateAgeRange(this.ageRange);

  @override
  List<Object?> get props => [ageRange];
}

class UpdateGenderPreference extends MatchPreferencesEvent {
  final List<String> genderPreference;

  const UpdateGenderPreference(this.genderPreference);

  @override
  List<Object?> get props => [genderPreference];
}

class UpdateBeerTypes extends MatchPreferencesEvent {
  final List<String> beerTypes;

  const UpdateBeerTypes(this.beerTypes);

  @override
  List<Object?> get props => [beerTypes];
}

class SaveMatchPreferences extends MatchPreferencesEvent {
  final MatchPreferences preferences;

  const SaveMatchPreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
