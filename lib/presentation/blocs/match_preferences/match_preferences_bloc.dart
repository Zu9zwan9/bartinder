import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/match_preferences_repository.dart';
import '../../../domain/entities/match_preferences.dart';

part 'match_preferences_event.dart';
part 'match_preferences_state.dart';

class MatchPreferencesBloc
    extends Bloc<MatchPreferencesEvent, MatchPreferencesState> {
  final MatchPreferencesRepository repository;
  final String userId;

  MatchPreferencesBloc({required this.repository, required this.userId})
    : super(MatchPreferencesInitial()) {
    on<LoadMatchPreferences>(_onLoadMatchPreferences);
    on<UpdateMaxDistance>(_onUpdateMaxDistance);
    on<UpdateAgeRange>(_onUpdateAgeRange);
    on<UpdateGenderPreference>(_onUpdateGenderPreference);
    on<UpdateBeerTypes>(_onUpdateBeerTypes);
    on<SaveMatchPreferences>(_onSaveMatchPreferences);
  }

  Future<void> _onLoadMatchPreferences(
    LoadMatchPreferences event,
    Emitter<MatchPreferencesState> emit,
  ) async {
    emit(MatchPreferencesLoading());
    try {
      final preferences = await repository.getMatchPreferences(userId);
      if (preferences != null) {
        emit(MatchPreferencesLoaded(preferences));
      } else {
        // Create default preferences
        final defaultPreferences = MatchPreferences(
          userId: userId,
          maxDistanceKm: 25,
          ageRange: const [18, 65],
          showMeInCityOnly: false,
          genderPreference: const [],
          beerTypes: const [],
        );
        emit(MatchPreferencesLoaded(defaultPreferences));
      }
    } catch (e) {
      emit(MatchPreferencesError('Failed to load preferences: $e'));
    }
  }

  Future<void> _onUpdateMaxDistance(
    UpdateMaxDistance event,
    Emitter<MatchPreferencesState> emit,
  ) async {
    if (state is MatchPreferencesLoaded) {
      final currentState = state as MatchPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        maxDistanceKm: event.maxDistance,
      );
      emit(MatchPreferencesLoaded(updatedPreferences));

      try {
        await repository.updateMaxDistance(userId, event.maxDistance);
      } catch (e) {
        emit(MatchPreferencesError('Failed to update distance: $e'));
      }
    }
  }

  Future<void> _onUpdateAgeRange(
    UpdateAgeRange event,
    Emitter<MatchPreferencesState> emit,
  ) async {
    if (state is MatchPreferencesLoaded) {
      final currentState = state as MatchPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        ageRange: event.ageRange,
      );
      emit(MatchPreferencesLoaded(updatedPreferences));

      try {
        await repository.updateAgeRange(userId, event.ageRange);
      } catch (e) {
        emit(MatchPreferencesError('Failed to update age range: $e'));
      }
    }
  }

  Future<void> _onUpdateGenderPreference(
    UpdateGenderPreference event,
    Emitter<MatchPreferencesState> emit,
  ) async {
    if (state is MatchPreferencesLoaded) {
      final currentState = state as MatchPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        genderPreference: event.genderPreference,
      );
      emit(MatchPreferencesLoaded(updatedPreferences));

      try {
        await repository.updateGenderPreference(userId, event.genderPreference);
      } catch (e) {
        emit(MatchPreferencesError('Failed to update gender preference: $e'));
      }
    }
  }

  Future<void> _onUpdateBeerTypes(
    UpdateBeerTypes event,
    Emitter<MatchPreferencesState> emit,
  ) async {
    if (state is MatchPreferencesLoaded) {
      final currentState = state as MatchPreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        beerTypes: event.beerTypes,
      );
      emit(MatchPreferencesLoaded(updatedPreferences));

      try {
        await repository.updateBeerTypes(userId, event.beerTypes);
      } catch (e) {
        emit(MatchPreferencesError('Failed to update beer types: $e'));
      }
    }
  }

  Future<void> _onSaveMatchPreferences(
    SaveMatchPreferences event,
    Emitter<MatchPreferencesState> emit,
  ) async {
    try {
      await repository.saveMatchPreferences(event.preferences);
      emit(MatchPreferencesLoaded(event.preferences));
    } catch (e) {
      emit(MatchPreferencesError('Failed to save preferences: $e'));
    }
  }
}
