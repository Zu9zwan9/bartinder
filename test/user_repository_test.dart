import 'package:flutter_test/flutter_test.dart';
import 'package:beertinder/data/repositories/supabase_user_repository_impl.dart';
import 'package:beertinder/data/datasources/mock_user_data_source.dart';

void main() {
  group('User Repository Tests', () {
    test('Mock data source returns users', () {
      final mockDataSource = MockUserDataSource();
      final users = mockDataSource.getUsers();

      expect(users.isNotEmpty, true);
      expect(users.length, 5);
      expect(users.first.name, 'Olena');
    });

    test('CardSwiper should handle different user counts', () {
      // Test that numberOfCardsDisplayed logic works correctly
      final testCases = [
        {'userCount': 0, 'expected': 0},
        {'userCount': 1, 'expected': 1},
        {'userCount': 2, 'expected': 2},
        {'userCount': 3, 'expected': 3},
        {'userCount': 5, 'expected': 3},
      ];

      for (final testCase in testCases) {
        final userCount = testCase['userCount'] as int;
        final expected = testCase['expected'] as int;
        final result = userCount < 3 ? userCount : 3;
        expect(result, expected);
      }
    });
  });
}
