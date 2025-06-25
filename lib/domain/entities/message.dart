// lib/domain/entities/message.dart

import 'package:equatable/equatable.dart';

/// Domain entity representing a chat message between matched users.
class Message extends Equatable {
  final String id;
  final String matchId;
  final String senderId;
  final String receiverId;
  final String? text;
  final String? mediaUrl;
  final String? topic;
  final String? extension;
  final String? event;
  final String? content;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime insertedAt;
  final DateTime? sentAt;

  const Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.receiverId,
    this.text,
    this.mediaUrl,
    this.topic,
    this.extension,
    this.event,
    this.content,
    this.payload,
    required this.createdAt,
    required this.updatedAt,
    required this.insertedAt,
    this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      matchId: json['match_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      receiverId: json['receiver_id']?.toString() ?? '',
      text: json['text']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      topic: json['topic']?.toString(),
      extension: json['extension']?.toString(),
      event: json['event']?.toString(),
      content: json['content']?.toString(),
      payload: json['payload'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: (json['updated_at'] != null)
          ? DateTime.parse(json['updated_at']?.toString() ?? '')
          : DateTime.parse(
              json['created_at']?.toString() ??
                  DateTime.now().toIso8601String(),
            ),
      insertedAt: (json['inserted_at'] != null)
          ? DateTime.parse(json['inserted_at']?.toString() ?? '')
          : DateTime.parse(
              json['created_at']?.toString() ??
                  DateTime.now().toIso8601String(),
            ),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at']?.toString() ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'match_id': matchId,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'text': text,
    'media_url': mediaUrl,
    'topic': topic,
    'extension': extension,
    'event': event,
    'content': content,
    'payload': payload,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'inserted_at': insertedAt.toIso8601String(),
    'sent_at': sentAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    matchId,
    senderId,
    receiverId,
    text,
    mediaUrl,
    topic,
    extension,
    event,
    content,
    payload,
    createdAt,
    updatedAt,
    insertedAt,
    sentAt,
  ];
}
