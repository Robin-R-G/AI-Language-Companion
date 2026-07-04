import '../../../../core/errors/result.dart';
import '../entities/mock_exam.dart';

abstract class MockExamRepository {
  Future<Result<List<MockExam>>> getExams({String? examType, String? section});
  Future<Result<MockExam>> getExamById(String id);
  Future<Result<MockExam>> startExam(String examId);
  Future<Result<ExamQuestion>> submitAnswer(
    String examId,
    String questionId,
    String answer,
  );
  Future<Result<MockExam>> completeExam(String examId);
  Future<Result<List<MockExam>>> getHistory({int limit = 20});
}
