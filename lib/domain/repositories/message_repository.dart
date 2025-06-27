// lib/domain/repositories/message_repository.dart

import '../entities/message.dart';

/// Repository interface for handling messages between matched users.
abstract class MessageRepository {
  /// Returns a stream of messages for a given match.
  Stream<List<Message>> getMessages(String matchId);

  /// Sends a message in a given match.
  Future<void> sendMessage(Message message);

  /// Edits an existing message.
  Future<void> editMessage(Message message);

  /// Deletes a message by its ID.
  Future<void> deleteMessage(String messageId);
}
