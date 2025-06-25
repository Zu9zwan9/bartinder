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
      // Remove fields not present in DB schema
      ..remove('inserted_at')
      ..remove('updated_at');
    final response = await _supabase.from('messages').insert(data);
    if (response.error != null) {
      throw Exception('Failed to send message: ${response.error!.message}');
    }
  }
}
