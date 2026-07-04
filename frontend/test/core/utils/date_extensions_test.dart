import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/date_extensions.dart';

void main() {
  group('DateTimeExtension', () {
    test('isToday returns true for today', () {
      expect(DateTime.now().isToday, true);
    });

    test('isYesterday returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isYesterday, true);
    });

    test('timeString formats correctly', () {
      final dt = DateTime(2026, 7, 4, 14, 30);
      expect(dt.timeString, '14:30');
    });

    test('dateString formats correctly', () {
      final dt = DateTime(2026, 7, 4);
      expect(dt.dateString, '4 Jul 2026');
    });

    test('dateTimeString combines date and time', () {
      final dt = DateTime(2026, 7, 4, 14, 30);
      expect(dt.dateTimeString, '4 Jul 2026, 14:30');
    });

    test('relativeTime returns Just now for recent', () {
      final now = DateTime.now();
      expect(now.relativeTime, 'Just now');
    });

    test('relativeTime returns minutes ago', () {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      expect(past.relativeTime, contains('minute(s) ago'));
    });

    test('relativeTime returns hours ago', () {
      final past = DateTime.now().subtract(const Duration(hours: 3));
      expect(past.relativeTime, '3 hour(s) ago');
    });

    test('relativeTime returns Yesterday', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(past.relativeTime, 'Yesterday');
    });
  });
}
