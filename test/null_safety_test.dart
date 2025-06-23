import 'package:flutter_test/flutter_test.dart';
import 'package:beertinder/domain/entities/user.dart';

void main() {
  group('Null Safety Tests', () {
    test('User entity should handle null and empty values gracefully', () {
      // Test creating a User with minimal required fields
      const user = User(
        id: '',
        name: 'Unknown',
        age: 0,
        photoUrl: '',
        favoriteBeer: 'Unknown',
      );

      expect(user.id, equals(''));
      expect(user.name, equals('Unknown'));
      expect(user.age, equals(0));
      expect(user.photoUrl, equals(''));
      expect(user.favoriteBeer, equals('Unknown'));
      expect(user.bio, isNull);
      expect(user.lastCheckedInLocation, isNull);
      expect(user.lastCheckedInDistance, isNull);
      expect(user.beerPreferences, equals([]));
    });

    test('User entity should handle optional fields properly', () {
      const user = User(
        id: 'test-id',
        name: 'Test User',
        age: 25,
        photoUrl: 'https://example.com/photo.jpg',
        favoriteBeer: 'IPA',
        bio: 'Test bio',
        lastCheckedInLocation: 'Test Location',
        lastCheckedInDistance: 1.5,
        beerPreferences: ['IPA', 'Stout'],
      );

      expect(user.id, equals('test-id'));
      expect(user.name, equals('Test User'));
      expect(user.age, equals(25));
      expect(user.photoUrl, equals('https://example.com/photo.jpg'));
      expect(user.favoriteBeer, equals('IPA'));
      expect(user.bio, equals('Test bio'));
      expect(user.lastCheckedInLocation, equals('Test Location'));
      expect(user.lastCheckedInDistance, equals(1.5));
      expect(user.beerPreferences, equals(['IPA', 'Stout']));
    });

    test('Map data parsing should handle null values', () {
      // Simulate database data with null values
      final Map<String, dynamic> nullData = {
        'id': null,
        'name': null,
        'age': null,
        'photo_url': null,
        'favorite_beer': null,
        'bio': null,
        'last_checked_in_location': null,
        'last_checked_in_distance': null,
        'beer_preferences': null,
      };

      // Test the null-safe parsing logic
      final user = User(
        id: nullData['id']?.toString() ?? '',
        name: nullData['name']?.toString() ?? 'Unknown',
        age: (nullData['age'] as int?) ?? 0,
        photoUrl: nullData['photo_url']?.toString() ?? '',
        favoriteBeer: nullData['favorite_beer']?.toString() ?? 'Unknown',
        bio: nullData['bio']?.toString(),
        lastCheckedInLocation: nullData['last_checked_in_location']?.toString(),
        lastCheckedInDistance: (nullData['last_checked_in_distance'] as num?)?.toDouble(),
        beerPreferences: List<String>.from(nullData['beer_preferences'] ?? []),
      );

      expect(user.id, equals(''));
      expect(user.name, equals('Unknown'));
      expect(user.age, equals(0));
      expect(user.photoUrl, equals(''));
      expect(user.favoriteBeer, equals('Unknown'));
      expect(user.bio, isNull);
      expect(user.lastCheckedInLocation, isNull);
      expect(user.lastCheckedInDistance, isNull);
      expect(user.beerPreferences, equals([]));
    });

    test('Map data parsing should handle mixed null and valid values', () {
      // Simulate database data with mixed null and valid values
      final Map<String, dynamic> mixedData = {
        'id': 'valid-id',
        'name': 'Valid Name',
        'age': 30,
        'photo_url': null,
        'favorite_beer': 'Lager',
        'bio': null,
        'last_checked_in_location': 'Valid Location',
        'last_checked_in_distance': null,
        'beer_preferences': ['Lager', 'Pilsner'],
      };

      // Test the null-safe parsing logic
      final user = User(
        id: mixedData['id']?.toString() ?? '',
        name: mixedData['name']?.toString() ?? 'Unknown',
        age: (mixedData['age'] as int?) ?? 0,
        photoUrl: mixedData['photo_url']?.toString() ?? '',
        favoriteBeer: mixedData['favorite_beer']?.toString() ?? 'Unknown',
        bio: mixedData['bio']?.toString(),
        lastCheckedInLocation: mixedData['last_checked_in_location']?.toString(),
        lastCheckedInDistance: (mixedData['last_checked_in_distance'] as num?)?.toDouble(),
        beerPreferences: List<String>.from(mixedData['beer_preferences'] ?? []),
      );

      expect(user.id, equals('valid-id'));
      expect(user.name, equals('Valid Name'));
      expect(user.age, equals(30));
      expect(user.photoUrl, equals(''));
      expect(user.favoriteBeer, equals('Lager'));
      expect(user.bio, isNull);
      expect(user.lastCheckedInLocation, equals('Valid Location'));
      expect(user.lastCheckedInDistance, isNull);
      expect(user.beerPreferences, equals(['Lager', 'Pilsner']));
    });
  });
}
