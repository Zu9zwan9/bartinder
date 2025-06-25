// lib/domain/usecases/get_messages_stream.dart

import '../entities/message.dart';
import '../repositories/message_repository.dart';

/// Use case for getting a stream of messages for a match.
class GetMessagesStream {
  final MessageRepository _repository;

  GetMessagesStream(this._repository);

  /// Returns a realtime stream of [Message]s for the given [matchId].
  Stream<List<Message>> execute(String matchId) {
    return _repository.getMessages(matchId);
  }
}
