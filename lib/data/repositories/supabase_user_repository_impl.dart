import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../services/auth_service.dart';

class SupabaseUserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId {
    final id = AuthService.currentUserId;
    if (id == null) throw Exception('Not signed in');
    return id;
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final currentId = _currentUserId;
      final data = await _supabase.from('users').select();

      return (data as List<dynamic>)
          .map((row) {
            final map = row as Map<String, dynamic>;
            // compute age from birth_date
            int age = 0;
            if (map['birth_date'] != null) {
              final birth = DateTime.parse(map['birth_date'] as String);
              final now = DateTime.now();
              age =
                  now.year -
                  birth.year -
                  ((now.month < birth.month ||
                          (now.month == birth.month && now.day < birth.day))
                      ? 1
                      : 0);
            }
            final interests = map['interests'] != null
                ? List<String>.from(map['interests'] as List)
                : <String>[];
            return User(
              id: map['id'] as String,
              name: map['name'] as String,
              age: age,
              photoUrl: map['avatar_url'] as String? ?? '',
              favoriteBeer: interests.isNotEmpty ? interests.first : '',
              bio: map['bio'] as String?,
              lastCheckedInLocation: null,
              lastCheckedInDistance: null,
              beerPreferences: interests,
            );
          })
          .where((u) => u.id != currentId)
          .toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  @override
  Future<void> likeUser(String userId) async {
    try {
      final currentId = _currentUserId;
      await _supabase.from('likes').insert({
        'from_user': currentId,
        'to_user': userId,
      });
    } catch (e) {
      throw Exception('Error liking user: $e');
    }
  }

  @override
  Future<void> dislikeUser(String userId) async {
    try {
      final currentId = _currentUserId;
      await _supabase
          .from('likes')
          .delete()
          .eq('from_user', currentId)
          .eq('to_user', userId);
    } catch (e) {
      throw Exception('Error disliking user: $e');
    }
  }

  @override
  Future<List<String>> getMatches() async {
    try {
      final currentId = _currentUserId;
      // users that current user liked
      final outgoing = await _supabase
          .from('likes')
          .select('to_user')
          .eq('from_user', currentId);
      final likedIds = (outgoing as List<dynamic>)
          .map((e) => e['to_user'] as String)
          .toList();
      // users that liked current user
      final incoming = await _supabase
          .from('likes')
          .select('from_user')
          .eq('to_user', currentId);
      final likerIds = (incoming as List<dynamic>)
          .map((e) => e['from_user'] as String)
          .toList();
      // mutual likes
      final mutual = likedIds.where((id) => likerIds.contains(id)).toList();
      return mutual;
    } catch (e) {
      throw Exception('Error getting matches: $e');
    }
  }
}
