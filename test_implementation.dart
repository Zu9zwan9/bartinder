import 'package:flutter_test/flutter_test.dart';
import 'lib/data/services/avatar_service.dart';
import 'lib/data/services/auth_service.dart';

void main() {
  group('Avatar Service Tests', () {
    test('generateAvatarUrl should return PNG URL', () {
      final url = AvatarService.generateAvatarUrl('test123');
      expect(url, contains('https://api.dicebear.com/6.x/notionists/png'));
      expect(url, contains('seed=test123'));
      expect(url, contains('backgroundColor=transparent'));
      expect(url, contains('size=200'));
    });
  });

  group('Auth Service Tests', () {
    test('generateRandomAvatar should return PNG URL', () {
      final url = AuthService.generateRandomAvatar();
      expect(url, contains('https://api.dicebear.com/6.x/notionists/png'));
      expect(url, contains('seed='));
    });
  });
}
