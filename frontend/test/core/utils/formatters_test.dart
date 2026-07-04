import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatDuration shows minutes', () {
      expect(Formatters.formatDuration(30), '30 min');
    });

    test('formatDuration shows hours', () {
      expect(Formatters.formatDuration(120), '2 hr');
    });

    test('formatDuration shows hours and minutes', () {
      expect(Formatters.formatDuration(90), '1 hr 30 min');
    });

    test('formatTimer shows MM:SS', () {
      expect(Formatters.formatTimer(90), '01:30');
      expect(Formatters.formatTimer(0), '00:00');
      expect(Formatters.formatTimer(3661), '61:01');
    });

    test('formatNumber adds commas', () {
      expect(Formatters.formatNumber(1000), '1,000');
      expect(Formatters.formatNumber(1000000), '1,000,000');
      expect(Formatters.formatNumber(123), '123');
    });

    test('formatXP abbreviates', () {
      expect(Formatters.formatXP(500), '500');
      expect(Formatters.formatXP(1500), '1.5K');
      expect(Formatters.formatXP(1500000), '1.5M');
    });

    test('formatPercentage converts decimal to percent', () {
      expect(Formatters.formatPercentage(0.75), '75%');
      expect(Formatters.formatPercentage(1.0), '100%');
    });

    test('formatBandScore formats to one decimal', () {
      expect(Formatters.formatBandScore(7.0), '7.0');
      expect(Formatters.formatBandScore(6.5), '6.5');
    });

    test('formatFileSize shows human readable sizes', () {
      expect(Formatters.formatFileSize(500), '500 B');
      expect(Formatters.formatFileSize(2048), '2.00 KB');
      expect(Formatters.formatFileSize(1048576), '1.00 MB');
    });
  });
}
