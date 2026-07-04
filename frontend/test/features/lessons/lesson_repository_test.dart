import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late LessonRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = LessonRepositoryImpl(dio: mockDio);
  });

  group('LessonRepositoryImpl', () {
    test('getLessons returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {
          'id': 'l1',
          'title': 'Lesson 1',
          'category': 'grammar',
          'difficulty': 'B1',
        },
        {
          'id': 'l2',
          'title': 'Lesson 2',
          'category': 'vocabulary',
          'difficulty': 'B2',
        },
      ]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getLessons();
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });

    test('getLessons filters by category', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      await repository.getLessons(category: 'grammar');
      verify(
        () => mockDio.get(
          any(),
          queryParameters: any(
            named: 'queryParameters',
            that: containsPair('category', 'grammar'),
          ),
        ),
      ).called(1);
    });

    test('getLessons handles invalid response', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'invalid': true});
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getLessons();
      expect(result.isFailure, true);
    });

    test('getLessonById returns lesson on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'id': 'l1',
        'title': 'Test',
        'category': 'grammar',
        'difficulty': 'B1',
      });
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getLessonById('l1');
      expect(result.isSuccess, true);
      expect(result.value.title, 'Test');
    });

    test('completeLesson returns data on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'xp_earned': 50, 'new_streak': 3});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.completeLesson('l1', 90);
      expect(result.isSuccess, true);
    });

    test('handles DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      final result = await repository.getLessons();
      expect(result.isFailure, true);
    });
  });
}
