import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/user_repository.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/distance_filter.dart';
import 'user_swipe_event.dart';
import 'user_swipe_state.dart';

/// BLoC for managing user swipe functionality
class UserSwipeBloc extends Bloc<UserSwipeEvent, UserSwipeState> {
  final UserRepository _userRepository;
  final LocationRepository _locationRepository;
  final LocationService _locationService;

  UserSwipeBloc({
    required UserRepository userRepository,
    LocationRepository? locationRepository,
    LocationService? locationService,
  }) : _userRepository = userRepository,
       _locationRepository = locationRepository ?? LocationRepository(),
       _locationService = locationService ?? LocationService(),
       super(const UserSwipeInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadUsersWithLocationFilter>(_onLoadUsersWithLocationFilter);
    on<UpdateDistanceFilter>(_onUpdateDistanceFilter);
    on<LikeUser>(_onLikeUser);
    on<DislikeUser>(_onDislikeUser);
    on<MatchCreated>(_onMatchCreated);
  }

  /// Handle the LoadUsers event
  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserSwipeState> emit,
  ) async {
    emit(const UserSwipeLoading());
    try {
      final users = await _userRepository.getUsers();
      final matches = await _userRepository.getMatches();
      emit(UserSwipeLoaded(users: users, matches: matches));
    } catch (e) {
      emit(UserSwipeError('Failed to load users: ${e.toString()}'));
    }
  }

  /// Handle the LikeUser event
  Future<void> _onLikeUser(LikeUser event, Emitter<UserSwipeState> emit) async {
    if (state is UserSwipeLoaded) {
      final currentState = state as UserSwipeLoaded;
      try {
        await _userRepository.likeUser(event.user.id);

        // TODO Check if this creates a match (in a real app, this would be determined by the backend)
        final matches = await _userRepository.getMatches();
        if (matches.contains(event.user.id)) {
          // If it's a match, emit the match state
          emit(UserSwipeMatch(event.user));

          // Then update the loaded state with the updated users list
          final updatedUsers = currentState.users
              .where((user) => user.id != event.user.id)
              .toList();
          emit(currentState.copyWith(users: updatedUsers, matches: matches));
        } else {
          // If it's not a match, just update the users list
          final updatedUsers = currentState.users
              .where((user) => user.id != event.user.id)
              .toList();
          emit(currentState.copyWith(users: updatedUsers));
        }
      } catch (e) {
        emit(UserSwipeError('Failed to like user: ${e.toString()}'));
      }
    }
  }

  /// Handle the DislikeUser event
  Future<void> _onDislikeUser(
    DislikeUser event,
    Emitter<UserSwipeState> emit,
  ) async {
    if (state is UserSwipeLoaded) {
      final currentState = state as UserSwipeLoaded;
      try {
        await _userRepository.dislikeUser(event.user.id);

        // Update the users list by removing the disliked user
        final updatedUsers = currentState.users
            .where((user) => user.id != event.user.id)
            .toList();
        emit(currentState.copyWith(users: updatedUsers));
      } catch (e) {
        emit(UserSwipeError('Failed to dislike user: ${e.toString()}'));
      }
    }
  }

  /// Handle the MatchCreated event
  void _onMatchCreated(MatchCreated event, Emitter<UserSwipeState> emit) {
    emit(UserSwipeMatch(event.matchedUser));

    // After showing the match, go back to the loaded state
    if (state is UserSwipeLoaded) {
      emit(state);
    } else {
      add(const LoadUsers());
    }
  }

  /// Handle the LoadUsersWithLocationFilter event
  Future<void> _onLoadUsersWithLocationFilter(
    LoadUsersWithLocationFilter event,
    Emitter<UserSwipeState> emit,
  ) async {
    emit(const UserSwipeLoading());
    try {
      // Get users filtered by distance
      final usersData = await _locationRepository.getUsersByDistanceFilter(
        latitude: event.latitude,
        longitude: event.longitude,
        distanceFilter: event.distanceFilter,
        excludeUserId: event.currentUserId,
      );

      // Convert to User entities
      final users = usersData.map((userData) => _mapToUser(userData)).toList();

      final matches = await _userRepository.getMatches();
      emit(UserSwipeLoaded(users: users, matches: matches));
    } catch (e) {
      emit(UserSwipeError('Failed to load users with location filter: ${e.toString()}'));
    }
  }

  /// Handle the UpdateDistanceFilter event
  Future<void> _onUpdateDistanceFilter(
    UpdateDistanceFilter event,
    Emitter<UserSwipeState> emit,
  ) async {
    // This event can be used to trigger a reload with new filter
    // For now, we'll just emit the current state
    // TODO: store the current location and reload
    if (state is UserSwipeLoaded) {
      emit(state);
    }
  }

  /// Helper method to convert Map to User entity
  User _mapToUser(Map<String, dynamic> userData) {
    return User(
      id: userData['id'] ?? '',
      name: userData['name'] ?? 'Unknown',
      age: _calculateAge(userData['birth_date']),
      photoUrl: userData['avatar_url'] ?? '',
      favoriteBeer: userData['interests']?.isNotEmpty == true
          ? userData['interests'][0]
          : 'Beer',
      bio: userData['bio'],
      latitude: (userData['latitude'] as num?)?.toDouble(),
      longitude: (userData['longitude'] as num?)?.toDouble(),
      distance: (userData['distance'] as num?)?.toDouble(),
      email: userData['email'],
      phone: userData['phone'],
      avatarUrl: userData['avatar_url'],
      gender: userData['gender'],
      city: userData['city'],
      country: userData['country'],
      interests: userData['interests'] != null
          ? List<String>.from(userData['interests'])
          : [],
      birthDate: userData['birth_date'] != null
          ? DateTime.tryParse(userData['birth_date'])
          : null,
      isPremium: userData['is_premium'] ?? false,
      lastActiveAt: userData['last_active_at'] != null
          ? DateTime.tryParse(userData['last_active_at'])
          : null,
      beerPreferences: userData['interests'] != null
          ? List<String>.from(userData['interests'])
          : [],
    );
  }

  /// Helper method to calculate age from birth date
  int _calculateAge(String? birthDateString) {
    if (birthDateString == null) return 25; // Default age

    try {
      final birthDate = DateTime.parse(birthDateString);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age > 0 ? age : 25;
    } catch (e) {
      return 25; // Default age if parsing fails
    }
  }
}
