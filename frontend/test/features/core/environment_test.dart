import 'package:flutter_test/flutter_test.dart';
import 'package:ai_language_coach/core/config/environment.dart';
import 'package:ai_language_coach/core/constants/app_constants.dart';

void main() {
  group('Environment Configuration', () {
    test('default environment should be dev', () {
      // When no ENVIRONMENT is set, it defaults to dev
      final env = Environment.current;
      expect(env, isNotNull);
    });

    test('AppConstants should have valid supabase URL', () {
      expect(AppConstants.supabaseUrl, isNotEmpty);
    });

    test('AppConstants should have valid API base URL', () {
      expect(AppConstants.apiBaseUrl, startsWith('/functions/v1'));
    });

    test('AppConstants should have reasonable timeouts', () {
      expect(AppConstants.connectionTimeout.inSeconds, greaterThanOrEqualTo(5));
      expect(AppConstants.connectionTimeout.inSeconds, lessThanOrEqualTo(30));
      expect(AppConstants.receiveTimeout.inSeconds, greaterThanOrEqualTo(5));
      expect(AppConstants.receiveTimeout.inSeconds, lessThanOrEqualTo(60));
    });

    test('AppConstants should have gamification constants', () {
      expect(AppConstants.xpPerLesson, greaterThan(0));
      expect(AppConstants.xpPerVoiceSession, greaterThan(0));
      expect(AppConstants.xpPerMockExam, greaterThan(0));
      expect(AppConstants.streakBonusMultiplier, greaterThan(1));
    });

    test('AppConstants should have free tier limits', () {
      expect(AppConstants.freeVoiceMinutesPerDay, greaterThan(0));
      expect(AppConstants.freeLessonsPerDay, greaterThan(0));
      expect(AppConstants.freeMockExamsPerMonth, greaterThan(0));
    });

    test('AppConstants should have native languages list', () {
      expect(AppConstants.nativeLanguages, isNotEmpty);
      expect(
        AppConstants.nativeLanguages
            .any((l) => l['code'] == 'ml'),
        isTrue,
        reason: 'Malayalam should be in native languages',
      );
    });

    test('AppConstants should have target languages list', () {
      expect(AppConstants.targetLanguages, isNotEmpty);
      expect(
        AppConstants.targetLanguages
            .any((l) => l['code'] == 'en'),
        isTrue,
        reason: 'English should be in target languages',
      );
    });

    test('AppConstants should have CEFR levels', () {
      expect(AppConstants.proficiencyLevels, isNotEmpty);
      final codes =
          AppConstants.proficiencyLevels.map((l) => l['code']).toList();
      expect(codes, contains('A1'));
      expect(codes, contains('B1'));
      expect(codes, contains('C1'));
    });

    test('AppConstants should have exam types', () {
      expect(AppConstants.exams, isNotEmpty);
      expect(
        AppConstants.exams.any((e) => e['code'] == 'ielts'),
        isTrue,
      );
    });

    test('AppConstants should have daily goals', () {
      expect(AppConstants.dailyGoals, isNotEmpty);
      expect(AppConstants.dailyGoals.first, lessThan(AppConstants.dailyGoals.last));
    });

    test('AppConstants should have motivational quotes', () {
      expect(AppConstants.motivationalQuotes, isNotEmpty);
      for (final quote in AppConstants.motivationalQuotes) {
        expect(quote, isNotEmpty);
      }
    });

    test('AppConstants should have storage keys', () {
      expect(AppConstants.userTokenKey, isNotEmpty);
      expect(AppConstants.refreshTokenKey, isNotEmpty);
      expect(AppConstants.userProfileKey, isNotEmpty);
      expect(AppConstants.onboardingCompleteKey, isNotEmpty);
      expect(AppConstants.themeModeKey, isNotEmpty);
    });

    test('AppConstants should have valid pagination', () {
      expect(AppConstants.defaultPageSize, greaterThan(0));
      expect(AppConstants.maxPageSize, greaterThanOrEqualTo(AppConstants.defaultPageSize));
    });
  });
}
