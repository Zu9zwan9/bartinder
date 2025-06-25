// lib/domain/usecases/send_message.dart

import '../entities/message.dart';
import '../repositories/message_repository.dart';

/// Use case for sending a message in a match.
class SendMessageUseCase {
  final MessageRepository _repository;

  SendMessageUseCase(this._repository);

  /// Sends a [message] via repository.
  Future<void> execute(Message message) async {
    await _repository.sendMessage(message);
  }
}
