class MessageModel {
  final String id;
  final String matchId;
  final String senderId;
  final String? text;
  final String? mediaUrl;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.matchId,
    required this.senderId,
    this.text,
    this.mediaUrl,
    required this.sentAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      matchId: map['match_id'] as String,
      senderId: map['sender_id'] as String,
      text: map['text'] as String?,
      mediaUrl: map['media_url'] as String?,
      sentAt: DateTime.parse(map['sent_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'match_id': matchId,
      'sender_id': senderId,
      'text': text,
      'media_url': mediaUrl,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}
