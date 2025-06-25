import 'package:bloc/bloc.dart';
import '../../../data/repositories/user_repository_impl.dart';
import 'user_actions_event.dart';
import 'user_actions_state.dart';

class UserActionsBloc extends Bloc<UserActionEvent, UserActionState> {
  final UserRepositoryImpl userRepository;

  UserActionsBloc({required this.userRepository}) : super(UserActionInitial()) {
    on<LikeUserEvent>(_onLikeUser);
    on<DislikeUserEvent>(_onDislikeUser);
  }

  Future<void> _onLikeUser(
    LikeUserEvent event,
    Emitter<UserActionState> emit,
  ) async {
    emit(UserActionInProgress());
    try {
      await userRepository.likeUser(event.userId);
      emit(const UserActionSuccess('User liked successfully'));
    } catch (e) {
      emit(UserActionFailure('Failed to like user: $e'));
    }
  }

  Future<void> _onDislikeUser(
    DislikeUserEvent event,
    Emitter<UserActionState> emit,
  ) async {
    emit(UserActionInProgress());
    try {
      await userRepository.dislikeUser(event.userId);
      emit(const UserActionSuccess('User disliked successfully'));
    } catch (e) {
      emit(UserActionFailure('Failed to dislike user: $e'));
    }
  }
}
