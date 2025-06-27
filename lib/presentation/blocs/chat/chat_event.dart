// lib/presentation/blocs/chat/chat_event.dart
import 'package:equatable/equatable.dart';

/// Events for ChatBloc
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger loading of messages stream
class LoadMessages extends ChatEvent {
  const LoadMessages();
}

/// New messages received from stream
class MessagesUpdated extends ChatEvent {
  final List<dynamic> messages; // will be cast to domain Message
  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Send a text message
class SendTextMessage extends ChatEvent {
  final String text;
  const SendTextMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// Internal event for chat stream errors
class ChatStreamError extends ChatEvent {
  final String error;
  const ChatStreamError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Edit a message
class EditMessage extends ChatEvent {
  final String messageId;
  final String newText;
  const EditMessage({required this.messageId, required this.newText});

  @override
  List<Object?> get props => [messageId, newText];
}

/// Delete a message
class DeleteMessage extends ChatEvent {
  final String messageId;
  const DeleteMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
