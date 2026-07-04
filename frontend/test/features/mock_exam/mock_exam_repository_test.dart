import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/mock_exam/data/repositories/mock_exam_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late MockExamRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = MockExamRepositoryImpl(dio: mockDio);
  });

  group('MockExamRepositoryImpl', () {
    test('getExams returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {
          'id': 'e1',
          'examType': 'IELTS',
          'section': 'Reading',
          'title': 'Test 1',
        },
        {
          'id': 'e2',
          'examType': 'IELTS',
          'section': 'Writing',
          'title': 'Test 2',
        },
      ]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getExams();
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });

    test('getExams filters by type', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      await repository.getExams(examType: 'IELTS');
      verify(
        () => mockDio.get(
          any(),
          queryParameters: any(
            named: 'queryParameters',
            that: containsPair('exam_type', 'IELTS'),
          ),
        ),
      ).called(1);
    });

    test('getExamById returns exam on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'id': 'e1',
        'examType': 'IELTS',
        'section': 'Reading',
        'title': 'Test 1',
      });
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getExamById('e1');
      expect(result.isSuccess, true);
      expect(result.value.examType, 'IELTS');
    });

    test('startExam returns exam on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'id': 'e1',
        'examType': 'IELTS',
        'section': 'Reading',
        'title': 'Test 1',
        'status': 'in_progress',
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.startExam('e1');
      expect(result.isSuccess, true);
    });

    test('submitAnswer returns question on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'id': 'q1',
        'question': 'What is X?',
        'type': 'mcq',
        'options': ['A', 'B'],
        'correctAnswer': 'A',
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.submitAnswer('e1', 'q1', 'A');
      expect(result.isSuccess, true);
    });

    test('completeExam returns exam on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'id': 'e1',
        'examType': 'IELTS',
        'section': 'Reading',
        'title': 'Test 1',
        'status': 'completed',
        'score': 7.5,
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.completeExam('e1');
      expect(result.isSuccess, true);
    });

    test('getHistory returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getHistory();
      expect(result.isSuccess, true);
    });

    test('handles DioException', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Exam service error',
        ),
      );

      final result = await repository.startExam('e1');
      expect(result.isFailure, true);
    });
  });
}
