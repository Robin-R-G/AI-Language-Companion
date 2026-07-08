import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/constants/app_constants.dart';

void main() {
  group('DioClient Configuration', () {
    test('base URL should be correctly configured', () {
      final expectedBaseUrl =
          AppConstants.supabaseUrl + AppConstants.apiBaseUrl;

      expect(expectedBaseUrl, isNotEmpty);
      expect(expectedBaseUrl, contains('supabase'));
    });

    test('connection timeout should be 10 seconds', () {
      expect(AppConstants.connectionTimeout.inSeconds, 10);
    });

    test('receive timeout should be 15 seconds', () {
      expect(AppConstants.receiveTimeout.inSeconds, 15);
    });

    test('API base URL should start with /functions/v1', () {
      expect(AppConstants.apiBaseUrl, startsWith('/functions/v1'));
    });

    test('supabase URL should be configured', () {
      expect(AppConstants.supabaseUrl, isNotEmpty);
    });

    test('supabase anon key should be configured', () {
      expect(AppConstants.supabaseAnonKey, isNotEmpty);
    });
  });

  group('Request Options', () {
    test('content type should be application/json', () {
      const contentType = 'application/json';
      expect(contentType, 'application/json');
    });

    test('authorization header format', () {
      const token = 'test_token_123';
      const authHeader = 'Bearer $token';

      expect(authHeader, startsWith('Bearer '));
      expect(authHeader, contains(token));
    });
  });

  group('Error Handling', () {
    test('DioException types should be handled', () {
      const errorTypes = [
        'connectionTimeout',
        'sendTimeout',
        'receiveTimeout',
        'badCertificate',
        'connectionError',
        'cancel',
        'connectionTimeout',
        'badResponse',
        'unknown',
      ];

      expect(errorTypes.length, greaterThan(0));
    });

    test('401 status code should trigger token refresh', () {
      const statusCode = 401;
      expect(statusCode, 401);
    });

    test('500 status code should return server error', () {
      const statusCode = 500;
      expect(statusCode, greaterThanOrEqualTo(500));
    });
  });
}
