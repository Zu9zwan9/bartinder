import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Service for sending and retrieving messages between users
class MessageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  MessageService();

  /// Sends a message from the current user to [toUserId] with [content]
  Future<void> sendMessage(String toUserId, String content) async {
    final fromUserId = AuthService.currentUserId;
    if (fromUserId == null) throw Exception('User not signed in');
    await _supabase.from('messages').insert({
      'from_user': fromUserId,
      'to_user': toUserId,
      'content': content,
    });
  }
}
