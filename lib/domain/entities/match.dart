import 'package:equatable/equatable.dart';

class Match extends Equatable {
  final String id;
  final String userId;
  final String matchedUserId;
  final DateTime matchedAt;
  final bool isAccepted;
  final String? barId; // ID of the bar where they plan to meet
  final DateTime? meetupTime; // Planned meetup time

  const Match({
    required this.id,
    required this.userId,
    required this.matchedUserId,
    required this.matchedAt,
    this.isAccepted = false,
    this.barId,
    this.meetupTime,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    matchedUserId,
    matchedAt,
    isAccepted,
    barId,
    meetupTime,
  ];
}
