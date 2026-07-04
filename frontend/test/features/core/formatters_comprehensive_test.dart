import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/formatters.dart';

void main() {
  group('Formatters - Comprehensive Tests', () {
    group('formatDuration', () {
      test('formats minutes only', () {
        expect(Formatters.formatDuration(5), '5 min');
      });

      test('formats hours only', () {
        expect(Formatters.formatDuration(60), '1 hr');
      });

      test('formats hours and minutes', () {
        expect(Formatters.formatDuration(90), '1 hr 30 min');
      });

      test('formats 0 minutes', () {
        expect(Formatters.formatDuration(0), '0 min');
      });

      test('formats large duration', () {
        expect(Formatters.formatDuration(150), '2 hr 30 min');
      });
    });

    group('formatTimer', () {
      test('formats 0 seconds', () {
        expect(Formatters.formatTimer(0), '00:00');
      });

      test('formats 30 seconds', () {
        expect(Formatters.formatTimer(30), '00:30');
      });

      test('formats 1 minute', () {
        expect(Formatters.formatTimer(60), '01:00');
      });

      test('formats 5 minutes 30 seconds', () {
        expect(Formatters.formatTimer(330), '05:30');
      });

      test('formats 59 minutes 59 seconds', () {
        expect(Formatters.formatTimer(3599), '59:59');
      });
    });

    group('formatNumber', () {
      test('formats small number', () {
        expect(Formatters.formatNumber(42), '42');
      });

      test('formats thousands', () {
        expect(Formatters.formatNumber(1000), '1,000');
      });

      test('formats large number', () {
        expect(Formatters.formatNumber(1234567), '1,234,567');
      });

      test('formats zero', () {
        expect(Formatters.formatNumber(0), '0');
      });
    });

    group('formatXP', () {
      test('formats small XP', () {
        expect(Formatters.formatXP(500), '500');
      });

      test('formats thousands as K', () {
        expect(Formatters.formatXP(1000), '1.0K');
      });

      test('formats millions as M', () {
        expect(Formatters.formatXP(1000000), '1.0M');
      });

      test('formats 999 as is', () {
        expect(Formatters.formatXP(999), '999');
      });
    });

    group('formatPercentage', () {
      test('formats 0%', () {
        expect(Formatters.formatPercentage(0.0), '0%');
      });

      test('formats 50%', () {
        expect(Formatters.formatPercentage(0.5), '50%');
      });

      test('formats 100%', () {
        expect(Formatters.formatPercentage(1.0), '100%');
      });

      test('formats partial percentage', () {
        expect(Formatters.formatPercentage(0.75), '75%');
      });
    });

    group('formatBandScore', () {
      test('formats whole number', () {
        expect(Formatters.formatBandScore(7.0), '7.0');
      });

      test('formats decimal score', () {
        expect(Formatters.formatBandScore(6.5), '6.5');
      });

      test('formats low score', () {
        expect(Formatters.formatBandScore(4.0), '4.0');
      });
    });

    group('formatFileSize', () {
      test('formats bytes', () {
        expect(Formatters.formatFileSize(500), '500 B');
      });

      test('formats kilobytes', () {
        expect(Formatters.formatFileSize(1024), '1.00 KB');
      });

      test('formats megabytes', () {
        expect(Formatters.formatFileSize(1048576), '1.00 MB');
      });

      test('formats gigabytes', () {
        expect(Formatters.formatFileSize(1073741824), '1.00 GB');
      });
    });
  });
}
