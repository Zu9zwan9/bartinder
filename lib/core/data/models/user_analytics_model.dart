class UserAnalyticsModel {
  final String userId;
  final int totalMatches;
  final int totalMessages;
  final int totalBarsVisited;
  final DateTime? lastBarCheckin;
  final String? favoriteBeerType;

  UserAnalyticsModel({
    required this.userId,
    required this.totalMatches,
    required this.totalMessages,
    required this.totalBarsVisited,
    this.lastBarCheckin,
    this.favoriteBeerType,
  });

  factory UserAnalyticsModel.fromMap(Map<String, dynamic> map) {
    return UserAnalyticsModel(
      userId: map['user_id'] as String,
      totalMatches: map['total_matches'] as int,
      totalMessages: map['total_messages'] as int,
      totalBarsVisited: map['total_bars_visited'] as int,
      lastBarCheckin: map['last_bar_checkin'] != null
          ? DateTime.parse(map['last_bar_checkin'] as String)
          : null,
      favoriteBeerType: map['favorite_beer_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'total_matches': totalMatches,
      'total_messages': totalMessages,
      'total_bars_visited': totalBarsVisited,
      'last_bar_checkin': lastBarCheckin?.toIso8601String(),
      'favorite_beer_type': favoriteBeerType,
    };
  }
}
