import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/bar_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/entities/user.dart';
import 'matches_event.dart';
import 'matches_state.dart';

/// BLoC for the Matches page
class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final UserRepositoryImpl _userRepository;
  final BarRepositoryImpl _barRepository;

  MatchesBloc({
    required UserRepositoryImpl userRepository,
    required BarRepositoryImpl barRepository,
  })  : _userRepository = userRepository,
        _barRepository = barRepository,
        super(const MatchesInitial()) {
    on<LoadPotentialMatches>(_onLoadPotentialMatches);
    on<RefreshPotentialMatches>(_onRefreshPotentialMatches);
    on<LikeUser>(_onLikeUser);
    on<DislikeUser>(_onDislikeUser);
    on<LoadMatches>(_onLoadMatches);
    on<SendMessage>(_onSendMessage);
    on<InviteToBar>(_onInviteToBar);
  }

  /// Convenience constructor with default dependencies
  factory MatchesBloc.withDefaultDependencies() {
    return MatchesBloc(
      userRepository: UserRepositoryImpl(),
      barRepository: BarRepositoryImpl(),
    );
  }

  Future<void> _onLoadPotentialMatches(
    LoadPotentialMatches event,
    Emitter<MatchesState> emit,
  ) async {
    emit(const PotentialMatchesLoading());
    try {
      final users = await _userRepository.getUsers();
      emit(PotentialMatchesLoaded(users));
    } catch (e) {
      emit(MatchesError('Failed to load potential matches: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshPotentialMatches(
    RefreshPotentialMatches event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      final users = await _userRepository.getUsers();
      emit(PotentialMatchesLoaded(users));
    } catch (e) {
      emit(MatchesError('Failed to refresh potential matches: ${e.toString()}'));
    }
  }

  Future<void> _onLikeUser(
    LikeUser event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await _userRepository.likeUser(event.userId);

      // Check if this is a match
      final matches = await _userRepository.getMatches();
      if (matches.contains(event.userId)) {
        // Get the user details
        final users = await _userRepository.getUsers();
        final matchedUser = users.firstWhere((user) => user.id == event.userId);
        emit(MatchFound(matchedUser));
      }

      // Refresh the potential matches
      add(const LoadPotentialMatches());
    } catch (e) {
      emit(MatchesError('Failed to like user: ${e.toString()}'));
    }
  }

  Future<void> _onDislikeUser(
    DislikeUser event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await _userRepository.dislikeUser(event.userId);

      // Refresh the potential matches
      add(const LoadPotentialMatches());
    } catch (e) {
      emit(MatchesError('Failed to dislike user: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMatches(
    LoadMatches event,
    Emitter<MatchesState> emit,
  ) async {
    emit(const MatchesLoading());
    try {
      final matchIds = await _userRepository.getMatches();
      final allUsers = await _userRepository.getUsers();

      // Filter users to get only matches
      final matches = allUsers.where((user) => matchIds.contains(user.id)).toList();

      emit(MatchesLoaded(matches));
    } catch (e) {
      emit(MatchesError('Failed to load matches: ${e.toString()}'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      // TODO In a real app, we would send the message to a backend
      // For now, we'll just emit a success state
      emit(MessageSent(event.userId, event.message));

      // Refresh the matches
      add(const LoadMatches());
    } catch (e) {
      emit(MatchesError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onInviteToBar(
    InviteToBar event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      // Get the bar name
      final bar = await _barRepository.getBarById(event.barId);
      if (bar != null) {
        // TODO In a real app, we would send the invitation to a backend
        // For now, we'll just emit a success state
        emit(InviteSent(event.userId, event.barId, bar.name));
      } else {
        emit(const MatchesError('Bar not found'));
      }

      // Refresh the matches
      add(const LoadMatches());
    } catch (e) {
      emit(MatchesError('Failed to send invitation: ${e.toString()}'));
    }
  }
}
