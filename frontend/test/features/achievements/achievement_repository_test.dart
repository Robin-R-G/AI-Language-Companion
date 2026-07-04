import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/achievements/data/repositories/achievement_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late AchievementRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = AchievementRepositoryImpl(dio: mockDio);
  });

  group('AchievementRepositoryImpl', () {
    test('getAchievements returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {
          'id': 'a1',
          'title': 'First!',
          'description': 'Desc',
          'icon': 'star',
          'category': 'milestone',
        },
        {
          'id': 'a2',
          'title': 'Streak 7',
          'description': '7 days',
          'icon': 'fire',
          'category': 'streak',
        },
      ]);
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getAchievements();
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });

    test('getAchievements handles invalid format', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'not': 'list'});
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getAchievements();
      expect(result.isFailure, true);
    });

    test('getProgress returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {'achievementId': 'a1', 'currentValue': 3, 'targetValue': 5},
      ]);
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getProgress();
      expect(result.isSuccess, true);
      expect(result.value.length, 1);
    });

    test('checkAndAward returns achievement on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'id': 'a1',
        'title': 'Unlocked!',
        'description': 'Desc',
        'icon': 'star',
        'category': 'milestone',
        'isUnlocked': true,
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.checkAndAward('a1');
      expect(result.isSuccess, true);
      expect(result.value.isUnlocked, true);
    });

    test('handles DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Failed to fetch',
        ),
      );

      final result = await repository.getAchievements();
      expect(result.isFailure, true);
    });
  });
}
