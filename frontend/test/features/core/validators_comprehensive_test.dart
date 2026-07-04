import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/validators.dart';

void main() {
  group('Validators - Comprehensive Tests', () {
    group('Email Validation', () {
      test('rejects null', () {
        expect(Validators.email(null), isNotNull);
      });

      test('rejects empty string', () {
        expect(Validators.email(''), isNotNull);
      });

      test('rejects invalid format - no @', () {
        expect(Validators.email('userexample.com'), isNotNull);
      });

      test('rejects invalid format - no domain', () {
        expect(Validators.email('user@'), isNotNull);
      });

      test('rejects invalid format - no TLD', () {
        expect(Validators.email('user@example'), isNotNull);
      });

      test('rejects invalid format - spaces', () {
        expect(Validators.email('user @example.com'), isNotNull);
      });

      test('accepts valid email', () {
        expect(Validators.email('user@example.com'), isNull);
      });

      test('accepts email with subdomain', () {
        expect(Validators.email('user@mail.example.com'), isNull);
      });

      test('accepts email with plus', () {
        expect(Validators.email('user+tag@example.com'), isNull);
      });

      test('accepts email with dots', () {
        expect(Validators.email('first.last@example.com'), isNull);
      });
    });

    group('Password Validation', () {
      test('rejects null', () {
        expect(Validators.password(null), isNotNull);
      });

      test('rejects empty string', () {
        expect(Validators.password(''), isNotNull);
      });

      test('rejects too short', () {
        expect(Validators.password('Ab1'), isNotNull);
      });

      test('rejects no uppercase', () {
        expect(Validators.password('lowercase1'), isNotNull);
      });

      test('rejects no lowercase', () {
        expect(Validators.password('UPPERCASE1'), isNotNull);
      });

      test('rejects no number', () {
        expect(Validators.password('NoNumberHere'), isNotNull);
      });

      test('accepts valid password', () {
        expect(Validators.password('ValidPass1'), isNull);
      });

      test('accepts long valid password', () {
        expect(Validators.password('MyStr0ngP@ssw0rd'), isNull);
      });
    });

    group('Confirm Password Validation', () {
      test('rejects null', () {
        expect(Validators.confirmPassword(null, 'password'), isNotNull);
      });

      test('rejects empty string', () {
        expect(Validators.confirmPassword('', 'password'), isNotNull);
      });

      test('rejects mismatch', () {
        expect(Validators.confirmPassword('password1', 'password'), isNotNull);
      });

      test('accepts matching passwords', () {
        expect(Validators.confirmPassword('password', 'password'), isNull);
      });
    });

    group('Required Field Validation', () {
      test('rejects null', () {
        expect(Validators.required(null), isNotNull);
      });

      test('rejects empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('accepts non-empty string', () {
        expect(Validators.required('value'), isNull);
      });

      test('custom field name in error message', () {
        final error = Validators.required(null, 'Username');
        expect(error, contains('Username'));
      });
    });

    group('Min Length Validation', () {
      test('rejects null', () {
        expect(Validators.minLength(null, 5), isNotNull);
      });

      test('rejects empty string', () {
        expect(Validators.minLength('', 5), isNotNull);
      });

      test('rejects too short', () {
        expect(Validators.minLength('abc', 5), isNotNull);
      });

      test('accepts exact length', () {
        expect(Validators.minLength('abcde', 5), isNull);
      });

      test('accepts longer string', () {
        expect(Validators.minLength('abcdef', 5), isNull);
      });
    });

    group('Phone Validation', () {
      test('rejects null', () {
        expect(Validators.phone(null), isNotNull);
      });

      test('rejects empty string', () {
        expect(Validators.phone(''), isNotNull);
      });

      test('rejects too short', () {
        expect(Validators.phone('12345'), isNotNull);
      });

      test('rejects non-numeric', () {
        expect(Validators.phone('abc1234567'), isNotNull);
      });

      test('accepts valid 10-digit phone', () {
        expect(Validators.phone('1234567890'), isNull);
      });

      test('accepts phone with + prefix', () {
        expect(Validators.phone('+1234567890'), isNull);
      });

      test('accepts 15-digit phone', () {
        expect(Validators.phone('123456789012345'), isNull);
      });
    });

    group('String Extension - isValidEmail', () {
      test('valid email via extension', () {
        expect('test@example.com'.isValidEmail, isTrue);
      });

      test('invalid email via extension', () {
        expect('not-an-email'.isValidEmail, isFalse);
      });
    });

    group('String Extension - isValidPassword', () {
      test('valid password via extension', () {
        expect('ValidPass1'.isValidPassword, isTrue);
      });

      test('invalid password via extension', () {
        expect('weak'.isValidPassword, isFalse);
      });
    });
  });
}
