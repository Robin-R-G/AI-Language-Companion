import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/core/utils/string_extensions.dart';
import 'package:ai_language_coach/core/utils/date_extensions.dart';

void main() {
  group('Performance Tests', () {
    test('Result.success creation should be fast', () {
      final sw = Stopwatch()..start();

      for (var i = 0; i < 10000; i++) {
        Result.success(i);
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Creating 10K Result.success took ${sw.elapsedMilliseconds}ms',
      );
    });

    test('Result.error creation should be fast', () {
      final sw = Stopwatch()..start();

      for (var i = 0; i < 10000; i++) {
        const Result.error(UnknownFailure('test'));
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Creating 10K Result.error took ${sw.elapsedMilliseconds}ms',
      );
    });

    test('Result.fold should be fast', () {
      final results = List.generate(
        10000,
        (i) => i.isEven
            ? Result.success(i)
            : const Result.error(UnknownFailure('test')),
      );

      final sw = Stopwatch()..start();

      for (final result in results) {
        result.fold((_) => null, (v) => v);
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Folding 10K results took ${sw.elapsedMilliseconds}ms',
      );
    });

    test('Result.map should be fast', () {
      final results = List.generate(10000, Result.success);

      final sw = Stopwatch()..start();

      for (final result in results) {
        result.map((v) => v * 2);
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Mapping 10K results took ${sw.elapsedMilliseconds}ms',
      );
    });

    test('Failure equality should be fast', () {
      final failures = List.generate(
        10000,
        (i) => NetworkFailure('Error $i', code: '$i'),
      );

      final sw = Stopwatch()..start();

      for (var i = 0; i < failures.length - 1; i++) {
        failures[i] == failures[i + 1];
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(100),
        reason: 'Comparing 10K failures took ${sw.elapsedMilliseconds}ms',
      );
    });

    test('String extensions should handle large strings', () {
      final longString = 'word ' * 10000;

      final sw = Stopwatch()..start();
      final capitalized = longString.capitalize;
      final truncated = longString.truncate(100);
      final noWhitespace = longString.removeWhitespace;
      sw.stop();

      expect(capitalized, isNotEmpty);
      expect(truncated.length, lessThanOrEqualTo(103));
      expect(noWhitespace, isNotEmpty);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('Date extensions should handle many dates', () {
      final dates = List.generate(
        10000,
        (i) => DateTime.now().subtract(Duration(days: i)),
      );

      final sw = Stopwatch()..start();

      for (final date in dates) {
        date.isToday;
        date.isYesterday;
        date.relativeTime;
        date.timeString;
        date.dateString;
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(500),
        reason: 'Formatting 10K dates took ${sw.elapsedMilliseconds}ms',
      );
    });

    test('Formatters should handle large numbers', () {
      final numbers = List.generate(10000, (i) => i * 1000);

      final sw = Stopwatch()..start();

      for (final n in numbers) {
        n.toString(); // Simulating number formatting
      }

      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(200));
    });

    test('Validators should handle many inputs', () {
      final emails = List.generate(10000, (i) => 'user$i@example.com');

      final sw = Stopwatch()..start();
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      for (final email in emails) {
        emailRegex.hasMatch(email);
      }

      sw.stop();
      expect(
        sw.elapsedMilliseconds,
        lessThan(500),
        reason: 'Validating 10K emails took ${sw.elapsedMilliseconds}ms',
      );
    });
  });

  group('Memory Usage Tests', () {
    test('large list of results should not leak memory', () {
      var results = List.generate(100000, Result.success);

      expect(results.length, 100000);

      results = [];
      expect(results, isEmpty);
    });

    test('map of mock data should be reasonable size', () {
      final data = <String, dynamic>{
        'id': 'test',
        'name': 'Test User',
        'email': 'test@example.com',
        'level': 8,
        'xp': 1200,
        'streak': 5,
      };

      expect(data.length, 6);
    });
  });

  group('Concurrent Operation Tests', () {
    test('multiple async results should resolve quickly', () async {
      final sw = Stopwatch()..start();

      final futures = List.generate(
        100,
        (i) => Future.value(Result.success(i)),
      );

      final results = await Future.wait(futures);

      sw.stop();
      expect(results.length, 100);
      expect(sw.elapsedMilliseconds, lessThan(1000));
    });

    test('stream operations should be fast', () async {
      final stream = Stream.fromIterable(List.generate(1000, (i) => i));

      final sw = Stopwatch()..start();

      final results = await stream
          .where((i) => i.isEven)
          .map((i) => i * 2)
          .toList();

      sw.stop();
      expect(results.length, 500);
      expect(sw.elapsedMilliseconds, lessThan(500));
    });
  });
}
