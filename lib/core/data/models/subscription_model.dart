class SubscriptionModel {
  final String id;
  final String userId;
  final String plan;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final String status;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startedAt,
    this.expiresAt,
    required this.status,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      plan: map['plan'] as String,
      startedAt: DateTime.parse(map['started_at'] as String),
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at'] as String) : null,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'status': status,
    };
  }
}
