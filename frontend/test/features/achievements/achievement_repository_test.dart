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
          'userId': 'user1',
          'badgeId': 'badge1',
          'title': 'First!',
          'description': 'Desc',
          'iconName': 'star',
          'xpReward': 100,
          'category': 'milestone',
          'tier': 'bronze',
          'unlockedAt': '2024-06-01T00:00:00.000',
          'createdAt': '2024-06-01T00:00:00.000',
        },
        {
          'id': 'a2',
          'userId': 'user1',
          'badgeId': 'badge2',
          'title': 'Streak 7',
          'description': '7 days',
          'iconName': 'fire',
          'xpReward': 200,
          'category': 'streak',
          'tier': 'silver',
          'unlockedAt': '2024-06-02T00:00:00.000',
          'createdAt': '2024-06-02T00:00:00.000',
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
        'userId': 'user1',
        'badgeId': 'badge1',
        'title': 'Unlocked!',
        'description': 'Desc',
        'iconName': 'star',
        'xpReward': 100,
        'category': 'milestone',
        'tier': 'bronze',
        'unlockedAt': '2024-06-01T00:00:00.000',
        'createdAt': '2024-06-01T00:00:00.000',
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.checkAndAward('a1');
      expect(result.isSuccess, true);
      expect(result.value.unlockedAt, DateTime.parse('2024-06-01T00:00:00.000'));
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
