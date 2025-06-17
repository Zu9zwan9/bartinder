import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/user_repository.dart';
import 'user_swipe_event.dart';
import 'user_swipe_state.dart';

/// BLoC for managing user swipe functionality
class UserSwipeBloc extends Bloc<UserSwipeEvent, UserSwipeState> {
  final UserRepository _userRepository;

  UserSwipeBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserSwipeInitial()) {
    on<LoadUsers>(_onLoadUsers);
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
  Future<void> _onLikeUser(
    LikeUser event,
    Emitter<UserSwipeState> emit,
  ) async {
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
          final updatedUsers = currentState.users.where((user) => user.id != event.user.id).toList();
          emit(currentState.copyWith(
            users: updatedUsers,
            matches: matches,
          ));
        } else {
          // If it's not a match, just update the users list
          final updatedUsers = currentState.users.where((user) => user.id != event.user.id).toList();
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
        final updatedUsers = currentState.users.where((user) => user.id != event.user.id).toList();
        emit(currentState.copyWith(users: updatedUsers));
      } catch (e) {
        emit(UserSwipeError('Failed to dislike user: ${e.toString()}'));
      }
    }
  }

  /// Handle the MatchCreated event
  void _onMatchCreated(
    MatchCreated event,
    Emitter<UserSwipeState> emit,
  ) {
    emit(UserSwipeMatch(event.matchedUser));

    // After showing the match, go back to the loaded state
    if (state is UserSwipeLoaded) {
      emit(state);
    } else {
      add(const LoadUsers());
    }
  }
}
