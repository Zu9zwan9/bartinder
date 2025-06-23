import 'package:flutter_test/flutter_test.dart';
import 'package:beertinder/data/services/avatar_service.dart';

void main() {
  group('Avatar Functionality Tests', () {
    test('generateAvatarUrl should return a valid DiceBear URL', () {
      const testSeed = 'test_user_123';
      final avatarUrl = AvatarService.generateAvatarUrl(testSeed);

      expect(avatarUrl, isNotNull);
      expect(avatarUrl, isNotEmpty);
      expect(avatarUrl, startsWith('https://api.dicebear.com/6.x/notionists/svg?seed='));
      expect(avatarUrl, contains('seed=$testSeed'));
      expect(avatarUrl, contains('backgroundColor=transparent'));
      expect(avatarUrl, contains('size=200'));
    });

    test('generateAvatarUrl should generate consistent URLs for same seed', () {
      const testSeed = 'consistent_seed_test';

      final avatarUrl1 = AvatarService.generateAvatarUrl(testSeed);
      final avatarUrl2 = AvatarService.generateAvatarUrl(testSeed);

      expect(avatarUrl1, equals(avatarUrl2),
        reason: 'Same seed should generate identical URLs');
    });

    test('generateAvatarUrl should generate different URLs for different seeds', () {
      const seed1 = 'user_seed_1';
      const seed2 = 'user_seed_2';

      final avatarUrl1 = AvatarService.generateAvatarUrl(seed1);
      final avatarUrl2 = AvatarService.generateAvatarUrl(seed2);

      expect(avatarUrl1, isNot(equals(avatarUrl2)),
        reason: 'Different seeds should generate different URLs');
    });

    test('avatar URL should contain valid parameters', () {
      const testSeed = 'param_test_seed';
      final avatarUrl = AvatarService.generateAvatarUrl(testSeed);
      final uri = Uri.parse(avatarUrl);

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('api.dicebear.com'));
      expect(uri.path, equals('/6.x/notionists/svg'));
      expect(uri.queryParameters.containsKey('seed'), isTrue);
      expect(uri.queryParameters.containsKey('backgroundColor'), isTrue);
      expect(uri.queryParameters.containsKey('size'), isTrue);

      final seed = uri.queryParameters['seed'];
      expect(seed, equals(testSeed));

      final backgroundColor = uri.queryParameters['backgroundColor'];
      expect(backgroundColor, equals('transparent'));

      final size = uri.queryParameters['size'];
      expect(size, equals('200'));
    });
  });
}
