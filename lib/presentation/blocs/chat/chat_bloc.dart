// lib/presentation/blocs/chat/chat_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/auth_service.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/get_messages_stream.dart';
import '../../../domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../data/repositories/message_repository_impl.dart';

/// BLoC for chat between current user and a matched user
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesStream _getMessagesStream;
  final SendMessageUseCase _sendMessageUseCase;
  final String _currentUserId;
  final String _otherUserId;
  late final StreamSubscription<List<Message>> _subscription;
  String? _matchId;

  ChatBloc({
    required GetMessagesStream getMessagesStream,
    required SendMessageUseCase sendMessageUseCase,
    required String currentUserId,
    required String otherUserId,
  })  : _getMessagesStream = getMessagesStream,
        _sendMessageUseCase = sendMessageUseCase,
        _currentUserId = currentUserId,
        _otherUserId = otherUserId,
        super(const ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<ChatStreamError>(_onChatStreamError);
    on<SendTextMessage>(_onSendTextMessage);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());
    try {
      // Find the match ID from the likes table
      _matchId = await _findMatchId();
      if (_matchId == null) {
        emit(const ChatError('No match found between users'));
        return;
      }

      _subscription = _getMessagesStream.execute(_matchId!).listen(
        (messages) => add(MessagesUpdated(messages)),
        onError: (error) => add(ChatStreamError(error.toString())),
      );
    } catch (e) {
      emit(ChatError('Failed to load messages: ${e.toString()}'));
    }
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    // Cast dynamic to domain Message
    final msgs = event.messages.cast<Message>();
    emit(ChatLoaded(msgs));
  }

  Future<void> _onSendTextMessage(
    SendTextMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      if (_matchId == null) {
        emit(const ChatError('No match found between users'));
        return;
      }

      final id = const Uuid().v4();
      final now = DateTime.now().toUtc();
      final message = Message(
        id: id,
        matchId: _matchId!,
        senderId: _currentUserId,
        receiverId: _otherUserId,
        text: event.text,
        mediaUrl: null,
        topic: null,
        extension: null,
        event: null,
        content: event.text, // Also set content field
        payload: null,
        createdAt: now,
        updatedAt: now,
        insertedAt: now,
        sentAt: now,
      );
      await _sendMessageUseCase.execute(message);
      // Optimistically update UI with new message
      if (state is ChatLoaded) {
        final updated = List<Message>.from((state as ChatLoaded).messages)
          ..add(message);
        emit(ChatLoaded(updated));
      }
    } catch (e) {
      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  void _onChatStreamError(ChatStreamError event, Emitter<ChatState> emit) {
    emit(ChatError(event.error));
  }

  /// Find the match ID from the likes table by looking for mutual likes
  Future<String?> _findMatchId() async {
    try {
      final supabase = Supabase.instance.client;

      // Look for a like from current user to other user (limit to 1 to handle duplicates)
      final outgoingLikes = await supabase
          .from('likes')
          .select('id')
          .eq('from_user', _currentUserId)
          .eq('to_user', _otherUserId)
          .limit(1);

      if (outgoingLikes.isNotEmpty) {
        // Check if there's also an incoming like (mutual match)
        final incomingLikes = await supabase
            .from('likes')
            .select('id')
            .eq('from_user', _otherUserId)
            .eq('to_user', _currentUserId)
            .limit(1);

        if (incomingLikes.isNotEmpty) {
          // Return the ID of the first like (stable ordering)
          final outgoingId = outgoingLikes.first['id'] as String;
          final incomingId = incomingLikes.first['id'] as String;
          final ids = [outgoingId, incomingId]..sort();
          return ids.first;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to find match ID: $e');
    }
  }

  /// Convenience constructor with default dependencies
  factory ChatBloc.withDefaultDependencies(String otherUserId) {
    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    final repo = SupabaseMessageRepositoryImpl();
    final getMessages = GetMessagesStream(repo);
    final sendMessageUseCase = SendMessageUseCase(repo);
    return ChatBloc(
      getMessagesStream: getMessages,
      sendMessageUseCase: sendMessageUseCase,
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
