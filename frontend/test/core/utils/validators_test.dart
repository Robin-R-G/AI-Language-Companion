import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error for null', () {
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for empty', () {
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for invalid format', () {
        expect(Validators.email('notanemail'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
      });
    });

    group('password', () {
      test('returns error for null', () {
        expect(Validators.password(null), isNotNull);
      });

      test('returns error for short password', () {
        expect(Validators.password('Ab1'), isNotNull);
      });

      test('returns error for missing uppercase', () {
        expect(Validators.password('abcdef1xyz'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('ValidPassword1'), isNull);
      });
    });

    group('confirmPassword', () {
      test('returns error for mismatch', () {
        expect(Validators.confirmPassword('abc', 'def'), isNotNull);
      });

      test('returns null for match', () {
        expect(Validators.confirmPassword('same', 'same'), isNull);
      });
    });

    group('required', () {
      test('returns error for empty', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns null for non-empty', () {
        expect(Validators.required('hello'), isNull);
      });
    });

    group('phone', () {
      test('returns error for invalid phone', () {
        expect(Validators.phone('123'), isNotNull);
      });

      test('returns null for valid phone', () {
        expect(Validators.phone('+1234567890'), isNull);
      });
    });
  });
}
