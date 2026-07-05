// lib/features/mock_exam/domain/repositories/mock_exam_repository.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/exam.dart';

abstract class MockExamRepository {
  Future<Result<List<MockExam>>> getExams({String? examType});
  Future<Result<MockExam>> startExam(String examId);
  Future<Result<ExamResult>> submitExam({
    required String attemptId,
    required List<Map<String, dynamic>> answers,
  });
  Future<Result<List<MockExam>>> getHistory(String userId);
}
