class MatchPreferenceModel {
  final String userId;
  final int? maxDistanceKm;
  final List<int>? ageRange;
  final List<String>? genderPreference;
  final List<String>? beerTypes;
  final bool showMeInCityOnly;

  MatchPreferenceModel({
    required this.userId,
    this.maxDistanceKm,
    this.ageRange,
    this.genderPreference,
    this.beerTypes,
    required this.showMeInCityOnly,
  });

  factory MatchPreferenceModel.fromMap(Map<String, dynamic> map) {
    return MatchPreferenceModel(
      userId: map['user_id'] as String,
      maxDistanceKm: map['max_distance_km'] as int?,
      ageRange: map['age_range'] != null
          ? List<int>.from(map['age_range'] as List)
          : null,
      genderPreference: map['gender_preference'] != null
          ? List<String>.from(map['gender_preference'] as List)
          : null,
      beerTypes: map['beer_types'] != null
          ? List<String>.from(map['beer_types'] as List)
          : null,
      showMeInCityOnly: map['show_me_in_city_only'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'max_distance_km': maxDistanceKm,
      'age_range': ageRange,
      'gender_preference': genderPreference,
      'beer_types': beerTypes,
      'show_me_in_city_only': showMeInCityOnly,
    };
  }
}
