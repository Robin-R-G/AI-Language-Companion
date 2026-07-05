import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';

void main() {
  group('Result', () {
    test('success creates a Result with value', () {
      const result = Result.success(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, 42);
    });

    test('error creates a Result with failure', () {
      const result = Result.error(const NetworkFailure('Timeout'));
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.failure.message, 'Timeout');
    });

    test('getOrElse returns value for success', () {
      const result = Result.success('data');
      expect(result.getOrElse(() => 'default'), 'data');
    });

    test('getOrElse returns default for failure', () {
      const result = Result.error(const NetworkFailure('Error'));
      expect(result.getOrElse(() => 'default'), 'default');
    });

    test('getOrNull returns value for success', () {
      const result = Result.success(99);
      expect(result.getOrNull(), 99);
    });

    test('getOrNull returns null for failure', () {
      const result = Result.error(const NetworkFailure('Error'));
      expect(result.getOrNull(), isNull);
    });

    test('map transforms success value', () {
      final result = const Result.success(10).map((v) => v * 2);
      expect(result.value, 20);
    });

    test('map propagates error without transforming', () {
      const Result<int> result = Result.error(const CacheFailure('miss'));
      final mapped = result.map((v) => v * 2);
      expect(mapped.isFailure, true);
      expect(mapped.failure.message, 'miss');
    });

    test('fold calls onSuccess for success', () {
      String? captured;
      const result = Result.success('ok');
      result.fold((f) {}, (v) => captured = v);
      expect(captured, 'ok');
    });

    test('fold calls onError for failure', () {
      Failure? captured;
      const result = Result.error(const AuthFailure('denied'));
      result.fold((f) => captured = f, (v) {});
      expect(captured, isA<AuthFailure>());
      expect(captured!.message, 'denied');
    });
  });

  group('Failure', () {
    test('Failure subclasses maintain message and code', () {
      const failure = NetworkFailure('Connection lost', code: 'NET_001');
      expect(failure.message, 'Connection lost');
      expect(failure.code, 'NET_001');
    });

    test('Failure subclasses are equatable', () {
      const a = NetworkFailure('err');
      const b = NetworkFailure('err');
      const c = NetworkFailure('diff');
      expect(a == b, true);
      expect(a == c, false);
      expect(a.hashCode == b.hashCode, true);
    });

    test('all failure types can be instantiated', () {
      expect(const NetworkFailure(''), isA<NetworkFailure>());
      expect(const AuthFailure(''), isA<AuthFailure>());
      expect(const DatabaseFailure(''), isA<DatabaseFailure>());
      expect(const CacheFailure(''), isA<CacheFailure>());
      expect(const ServerFailure(''), isA<ServerFailure>());
      expect(const ValidationFailure(''), isA<ValidationFailure>());
      expect(const AIServiceFailure(''), isA<AIServiceFailure>());
      expect(const VoiceServiceFailure(''), isA<VoiceServiceFailure>());
      expect(const PaymentFailure(''), isA<PaymentFailure>());
      expect(const UnknownFailure(''), isA<UnknownFailure>());
    });
  });
}
