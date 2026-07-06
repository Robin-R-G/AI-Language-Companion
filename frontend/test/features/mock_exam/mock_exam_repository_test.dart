import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_language_coach/features/mock_exam/data/repositories/mock_exam_repository_impl.dart';
import 'package:ai_language_coach/features/mock_exam/data/datasources/mock_exam_remote_datasource.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/shared/models/exam.dart';
import '../../mocks/mocks.dart';

class MockExamDataSource extends Mock implements MockExamRemoteDataSource {}

void main() {
  late MockExamDataSource mockDataSource;
  late MockExamRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockExamDataSource();
    repository = MockExamRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('MockExamRepositoryImpl', () {
    test('getExams returns list on success', () async {
      when(() => mockDataSource.getExams()).thenAnswer((_) async => const Result.success([]));

      final result = await repository.getExams();
      expect(result.isSuccess, true);
      expect(result.value.length, 0);
    });

    test('getExams filters by type', () async {
      when(() => mockDataSource.getExams(examType: any(named: 'examType')))
          .thenAnswer((_) async => const Result.success([]));

      await repository.getExams(examType: 'IELTS');
      verify(
        () => mockDataSource.getExams(examType: 'IELTS'),
      ).called(1);
    });

    test('startExam returns exam on success', () async {
      when(() => mockDataSource.startExam(any())).thenAnswer((_) async => Result.success(
        const MockExam(
          id: 'e1',
          examType: 'IELTS',
          section: 'Reading',
          duration: 60,
        ),
      ));

      final result = await repository.startExam('e1');
      expect(result.isSuccess, true);
    });

    test('submitExam returns result on success', () async {
      when(() => mockDataSource.submitExam(
        attemptId: any(named: 'attemptId'),
        answers: any(named: 'answers'),
      )).thenAnswer((_) async => Result.success(
        const ExamResult(
          id: 'er_1',
          examId: 'e1',
          estimatedScore: '7.5',
        ),
      ));

      final result = await repository.submitExam(
        attemptId: 'e1',
        answers: [{'question': 'q1', 'answer': 'A'}],
      );
      expect(result.isSuccess, true);
    });

    test('getHistory returns list on success', () async {
      when(() => mockDataSource.getHistory(any()))
          .thenAnswer((_) async => const Result.success([]));

      final result = await repository.getHistory('user_1');
      expect(result.isSuccess, true);
    });

    test('handles error', () async {
      when(() => mockDataSource.startExam(any()))
          .thenAnswer((_) async => Result.error(NetworkFailure('Exam service error')));

      final result = await repository.startExam('e1');
      expect(result.isFailure, true);
    });
  });
}
