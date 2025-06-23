import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

/// Service for sending bar invitations between users using Supabase
class InvitationService {
  final SupabaseClient _supabase;

  InvitationService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Sends an invitation from the current user to [toUserId] for [barId]
  Future<void> sendInvite(String toUserId, String barId) async {
    final fromUserId = AuthService.currentUserId;

    if (fromUserId == null) {
      throw Exception('User must be authenticated to send invitations');
    }

    try {
      if (kDebugMode) {
        print('Sending invitation from $fromUserId to $toUserId for bar $barId');
      }

      await _supabase.from('bar_invitations').insert({
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'bar_id': barId,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      if (kDebugMode) {
        print('Invitation sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send invitation: $e');
      }
      rethrow;
    }
  }

  /// Gets all invitations sent by the current user
  Future<List<Map<String, dynamic>>> getSentInvitations() async {
    final fromUserId = AuthService.currentUserId;

    if (fromUserId == null) {
      throw Exception('User must be authenticated to get invitations');
    }

    try {
      final response = await _supabase
          .from('bar_invitations')
          .select()
          .eq('from_user_id', fromUserId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get sent invitations: $e');
      }
      rethrow;
    }
  }

  /// Gets all invitations received by the current user
  Future<List<Map<String, dynamic>>> getReceivedInvitations() async {
    final toUserId = AuthService.currentUserId;

    if (toUserId == null) {
      throw Exception('User must be authenticated to get invitations');
    }

    try {
      final response = await _supabase
          .from('bar_invitations')
          .select()
          .eq('to_user_id', toUserId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get received invitations: $e');
      }
      rethrow;
    }
  }

  /// Updates the status of an invitation
  Future<void> updateInvitationStatus(String invitationId, String status) async {
    try {
      if (kDebugMode) {
        print('Updating invitation $invitationId status to $status');
      }

      await _supabase
          .from('bar_invitations')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);

      if (kDebugMode) {
        print('Invitation status updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update invitation status: $e');
      }
      rethrow;
    }
  }

  /// Accepts an invitation
  Future<void> acceptInvitation(String invitationId) async {
    await updateInvitationStatus(invitationId, 'accepted');
  }

  /// Declines an invitation
  Future<void> declineInvitation(String invitationId) async {
    await updateInvitationStatus(invitationId, 'declined');
  }
}
