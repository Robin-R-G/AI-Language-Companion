import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';

void main() {
  group('Result', () {
    test('Result.success stores value', () {
      const result = Result<int>.success(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, 42);
    });

    test('Result.error stores failure', () {
      const result = Result<int>.error(NetworkFailure('Network error'));
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.failure.message, 'Network error');
    });

    test('value getter throws on error', () {
      const result = Result<int>.error(NetworkFailure('err'));
      expect(() => result.value, throwsStateError);
    });

    test('failure getter throws on success', () {
      const result = Result<int>.success(10);
      expect(() => result.failure, throwsStateError);
    });

    test('fold calls onSuccess for success', () {
      const result = Result<String>.success('hello');
      String? captured;
      result.fold((_) => fail('should not call onError'), (v) => captured = v);
      expect(captured, 'hello');
    });

    test('fold calls onError for failure', () {
      const result = Result<int>.error(NetworkFailure('err'));
      Failure? captured;
      result.fold(
        (f) => captured = f,
        (_) => fail('should not call onSuccess'),
      );
      expect(captured, isA<NetworkFailure>());
    });

    test('map transforms success value', () {
      const result = Result<int>.success(5);
      final mapped = result.map((v) => v * 2);
      expect(mapped.value, 10);
    });

    test('map passes through error', () {
      const result = Result<int>.error(NetworkFailure('err'));
      final mapped = result.map((v) => v * 2);
      expect(mapped.isFailure, true);
    });

    test('getOrElse returns value on success', () {
      expect(const Result<int>.success(3).getOrElse(() => 0), 3);
    });

    test('getOrElse returns default on error', () {
      expect(
        const Result<int>.error(NetworkFailure('err')).getOrElse(() => 99),
        99,
      );
    });

    test('getOrNull returns value on success', () {
      expect(const Result<int>.success(3).getOrNull(), 3);
    });

    test('getOrNull returns null on error', () {
      expect(
        const Result<int>.error(NetworkFailure('err')).getOrNull(),
        isNull,
      );
    });
  });

  group('Failure', () {
    test('NetworkFailure has correct type', () {
      const f = NetworkFailure('timeout', code: '408');
      expect(f.message, 'timeout');
      expect(f.code, '408');
    });

    test('AuthFailure has correct type', () {
      expect(const AuthFailure('bad login'), isA<Failure>());
    });

    test('equality works for failures', () {
      const a = NetworkFailure('err');
      const b = NetworkFailure('err');
      const c = NetworkFailure('different');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('all failure types exist', () {
      expect(const NetworkFailure(''), isA<Failure>());
      expect(const AuthFailure(''), isA<Failure>());
      expect(const DatabaseFailure(''), isA<Failure>());
      expect(const CacheFailure(''), isA<Failure>());
      expect(const ServerFailure(''), isA<Failure>());
      expect(const ValidationFailure(''), isA<Failure>());
      expect(const AIServiceFailure(''), isA<Failure>());
      expect(const VoiceServiceFailure(''), isA<Failure>());
      expect(const PaymentFailure(''), isA<Failure>());
      expect(const UnknownFailure(''), isA<Failure>());
    });
  });
}
