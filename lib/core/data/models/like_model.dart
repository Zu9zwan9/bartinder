class LikeModel {
  final String id;
  final String fromUser;
  final String toUser;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.createdAt,
  });

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      id: map['id'] as String,
      fromUser: map['from_user'] as String,
      toUser: map['to_user'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_user': fromUser,
      'to_user': toUser,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
