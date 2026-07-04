import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';

void main() {
  group('Result', () {
    test('Result.success stores value', () {
      final result = Result.success(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, 42);
    });

    test('Result.error stores failure', () {
      final result = Result.error(NetworkFailure('Network error'));
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.failure.message, 'Network error');
    });

    test('value getter throws on error', () {
      final result = Result.error(NetworkFailure('err'));
      expect(() => result.value, throwsStateError);
    });

    test('failure getter throws on success', () {
      final result = Result.success(10);
      expect(() => result.failure, throwsStateError);
    });

    test('fold calls onSuccess for success', () {
      final result = Result.success('hello');
      String? captured;
      result.fold((_) => fail('should not call onError'), (v) => captured = v);
      expect(captured, 'hello');
    });

    test('fold calls onError for failure', () {
      final result = Result.error(NetworkFailure('err'));
      Failure? captured;
      result.fold(
        (f) => captured = f,
        (_) => fail('should not call onSuccess'),
      );
      expect(captured, isA<NetworkFailure>());
    });

    test('map transforms success value', () {
      final result = Result.success(5);
      final mapped = result.map((v) => v * 2);
      expect(mapped.value, 10);
    });

    test('map passes through error', () {
      final Result<int> result = Result.error(NetworkFailure('err'));
      final mapped = result.map((v) => v * 2);
      expect(mapped.isFailure, true);
    });

    test('getOrElse returns value on success', () {
      expect(Result.success(3).getOrElse(() => 0), 3);
    });

    test('getOrElse returns default on error', () {
      final Result<int> result = Result.error(NetworkFailure('err'));
      expect(result.getOrElse(() => 99), 99);
    });

    test('getOrNull returns value on success', () {
      expect(Result.success(3).getOrNull(), 3);
    });

    test('getOrNull returns null on error', () {
      final Result<int> result = Result.error(NetworkFailure('err'));
      expect(result.getOrNull(), isNull);
    });
  });

  group('Failure', () {
    test('NetworkFailure has correct type', () {
      final f = NetworkFailure('timeout', code: '408');
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
