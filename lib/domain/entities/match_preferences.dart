import 'package:equatable/equatable.dart';

/// Represents user's matching preferences for finding nearby users
class MatchPreferences extends Equatable {
  final String userId;
  final int maxDistanceKm;
  final List<int> ageRange; // [minAge, maxAge]
  final bool showMeInCityOnly;
  final List<String> genderPreference;
  final List<String> beerTypes;

  const MatchPreferences({
    required this.userId,
    required this.maxDistanceKm,
    required this.ageRange,
    required this.showMeInCityOnly,
    required this.genderPreference,
    required this.beerTypes,
  });

  MatchPreferences copyWith({
    String? userId,
    int? maxDistanceKm,
    List<int>? ageRange,
    bool? showMeInCityOnly,
    List<String>? genderPreference,
    List<String>? beerTypes,
  }) {
    return MatchPreferences(
      userId: userId ?? this.userId,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      ageRange: ageRange ?? this.ageRange,
      showMeInCityOnly: showMeInCityOnly ?? this.showMeInCityOnly,
      genderPreference: genderPreference ?? this.genderPreference,
      beerTypes: beerTypes ?? this.beerTypes,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    maxDistanceKm,
    ageRange,
    showMeInCityOnly,
    genderPreference,
    beerTypes,
  ];
}
