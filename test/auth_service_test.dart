import 'package:flutter_test/flutter_test.dart';
import 'package:beertinder/data/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('AuthResult success creation', () {
      const testData = 'test_data';
      final result = AuthResult.success(testData);

      expect(result.isSuccess, true);
      expect(result.data, testData);
      expect(result.error, null);
    });

    test('AuthResult failure creation', () {
      const testError = AuthException(
        code: 'test_error',
        message: 'Test error message',
      );
      final result = AuthResult.failure(testError);

      expect(result.isSuccess, false);
      expect(result.data, null);
      expect(result.error, testError);
    });

    test('AuthException toString', () {
      const exception = AuthException(
        code: 'test_code',
        message: 'Test message',
      );

      expect(exception.toString(), 'AuthException: test_code - Test message');
    });
  });
}
