// lib/features/mock_exam/data/repositories/mock_exam_repository_impl.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/exam.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../datasources/mock_exam_remote_datasource.dart';

class MockExamRepositoryImpl implements MockExamRepository {
  final MockExamRemoteDataSource _remoteDataSource;

  MockExamRepositoryImpl({MockExamRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MockExamRemoteDataSourceImpl();

  @override
  Future<Result<List<MockExam>>> getExams({String? examType}) {
    return _remoteDataSource.getExams(examType: examType);
  }

  @override
  Future<Result<MockExam>> startExam(String examId) {
    return _remoteDataSource.startExam(examId);
  }

  @override
  Future<Result<ExamResult>> submitExam({
    required String attemptId,
    required List<Map<String, dynamic>> answers,
  }) {
    return _remoteDataSource.submitExam(attemptId: attemptId, answers: answers);
  }

  @override
  Future<Result<List<MockExam>>> getHistory(String userId) {
    return _remoteDataSource.getHistory(userId);
  }
}
