import 'package:flutter_test/flutter_test.dart';
import 'package:beertinder/data/services/auth_service.dart';

void main() {
  group('Avatar Functionality Tests', () {
    test('generateRandomAvatar should return a valid DiceBear URL', () {
      final avatarUrl = AuthService.generateRandomAvatar();

      expect(avatarUrl, isNotNull);
      expect(avatarUrl, isNotEmpty);
      expect(avatarUrl, startsWith('https://api.dicebear.com/6.x/notionists/svg?seed='));

      // Test that multiple calls generate different URLs
      final avatarUrl2 = AuthService.generateRandomAvatar();
      expect(avatarUrl, isNot(equals(avatarUrl2)));
    });

    test('generateRandomAvatar should generate URLs with different seeds', () {
      final urls = <String>{};

      // Generate 10 URLs and ensure they're all different
      for (int i = 0; i < 10; i++) {
        final url = AuthService.generateRandomAvatar();
        urls.add(url);
      }

      expect(urls.length, equals(10), reason: 'All generated URLs should be unique');
    });

    test('avatar URL should contain valid seed parameter', () {
      final avatarUrl = AuthService.generateRandomAvatar();
      final uri = Uri.parse(avatarUrl);

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('api.dicebear.com'));
      expect(uri.path, equals('/6.x/notionists/svg'));
      expect(uri.queryParameters.containsKey('seed'), isTrue);

      final seed = uri.queryParameters['seed'];
      expect(seed, isNotNull);
      expect(seed, isNotEmpty);

      // Seed should be a valid number
      final seedNumber = int.tryParse(seed!);
      expect(seedNumber, isNotNull);
      expect(seedNumber! >= 0 && seedNumber < 1000000, isTrue);
    });
  });
}
