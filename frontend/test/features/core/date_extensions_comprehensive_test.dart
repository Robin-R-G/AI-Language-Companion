import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/date_extensions.dart';

void main() {
  group('DateTimeExtension - Comprehensive Tests', () {
    group('isToday', () {
      test('returns true for current date', () {
        expect(DateTime.now().isToday, isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday, isFalse);
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday, isTrue);
      });

      test('returns false for today', () {
        expect(DateTime.now().isYesterday, isFalse);
      });

      test('returns false for two days ago', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(twoDaysAgo.isYesterday, isFalse);
      });
    });

    group('isThisWeek', () {
      test('returns true for today', () {
        expect(DateTime.now().isThisWeek, isTrue);
      });

      test('returns true for 3 days ago', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(threeDaysAgo.isThisWeek, isTrue);
      });

      test('returns false for 10 days ago', () {
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        expect(tenDaysAgo.isThisWeek, isFalse);
      });
    });

    group('timeString', () {
      test('formats midnight', () {
        final dt = DateTime(2026, 7, 4, 0);
        expect(dt.timeString, '00:00');
      });

      test('formats noon', () {
        final dt = DateTime(2026, 7, 4, 12, 30);
        expect(dt.timeString, '12:30');
      });

      test('formats single digit hours', () {
        final dt = DateTime(2026, 7, 4, 9, 5);
        expect(dt.timeString, '09:05');
      });
    });

    group('dateString', () {
      test('formats January', () {
        final dt = DateTime(2026, 1, 15);
        expect(dt.dateString, '15 Jan 2026');
      });

      test('formats December', () {
        final dt = DateTime(2026, 12, 25);
        expect(dt.dateString, '25 Dec 2026');
      });

      test('formats July', () {
        final dt = DateTime(2026, 7, 4);
        expect(dt.dateString, '4 Jul 2026');
      });
    });

    group('dateTimeString', () {
      test('combines date and time', () {
        final dt = DateTime(2026, 7, 4, 14, 30);
        expect(dt.dateTimeString, '4 Jul 2026, 14:30');
      });
    });

    group('relativeTime', () {
      test('just now for recent time', () {
        final now = DateTime.now();
        expect(now.relativeTime, 'Just now');
      });

      test('minutes ago', () {
        final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
        expect(fiveMinAgo.relativeTime, contains('minute'));
      });

      test('hours ago', () {
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        expect(twoHoursAgo.relativeTime, contains('hour'));
      });

      test('yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.relativeTime, 'Yesterday');
      });

      test('days ago', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(threeDaysAgo.relativeTime, contains('day'));
      });

      test('months ago', () {
        final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
        expect(twoMonthsAgo.relativeTime, contains('month'));
      });

      test('years ago', () {
        final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
        expect(twoYearsAgo.relativeTime, contains('year'));
      });
    });
  });
}
