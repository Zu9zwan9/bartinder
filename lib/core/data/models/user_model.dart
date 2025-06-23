import 'location_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String passwordHash;
  final String? avatarUrl;
  final String? gender;
  final DateTime? birthDate;
  final String? bio;
  final LocationModel? location;
  final String? city;
  final String? country;
  final List<String>? interests;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.passwordHash,
    this.avatarUrl,
    this.gender,
    this.birthDate,
    this.bio,
    this.location,
    this.city,
    this.country,
    this.interests,
    required this.isPremium,
    required this.createdAt,
    this.lastActiveAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      passwordHash: map['password_hash'] as String,
      avatarUrl: map['avatar_url'] as String?,
      gender: map['gender'] as String?,
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date'] as String) : null,
      bio: map['bio'] as String?,
      location: map['location'] != null ? LocationModel.fromMap(map['location'] as Map<String, dynamic>) : null,
      city: map['city'] as String?,
      country: map['country'] as String?,
      interests: map['interests'] != null ? List<String>.from(map['interests'] as List) : null,
      isPremium: map['is_premium'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastActiveAt: map['last_active_at'] != null ? DateTime.parse(map['last_active_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'avatar_url': avatarUrl,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'bio': bio,
      'location': location?.toMap(),
      'city': city,
      'country': country,
      'interests': interests,
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }
}
