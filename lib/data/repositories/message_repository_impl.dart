// lib/data/repositories/message_repository_impl.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';

/// Supabase implementation of [MessageRepository].
class SupabaseMessageRepositoryImpl implements MessageRepository {
  final SupabaseClient _supabase;

  SupabaseMessageRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<Message>> getMessages(String matchId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true)
        .map((records) => records.map((e) => Message.fromJson(e)).toList());
  }

  @override
  Future<void> sendMessage(Message message) async {
    final data = message.toJson()
      ..removeWhere((_, value) => value == null)
      ..remove('inserted_at')
      ..remove('updated_at');
    try {
      await _supabase.from('messages').insert(data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> editMessage(Message message) async {
    final data = message.toJson()
      ..removeWhere((_, value) => value == null)
      ..remove('inserted_at')
      ..remove('updated_at');
    try {
      await _supabase.from('messages').update(data).eq('id', message.id);
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}
