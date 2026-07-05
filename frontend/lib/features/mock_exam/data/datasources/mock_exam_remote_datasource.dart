// lib/features/mock_exam/data/datasources/mock_exam_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../shared/models/exam.dart';

abstract class MockExamRemoteDataSource {
  Future<Result<List<Map<String, dynamic>>>> getExams({String? examType});
  Future<Result<MockExam>> startExam(String examId);
  Future<Result<ExamResult>> submitExam({
    required String attemptId,
    required List<Map<String, dynamic>> answers,
  });
  Future<Result<List<Map<String, dynamic>>>> getHistory(String userId);
}

class MockExamRemoteDataSourceImpl implements MockExamRemoteDataSource {
  final SupabaseClient _client;

  MockExamRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<List<Map<String, dynamic>>>> getExams({String? examType}) async {
    try {
      var query = _client.from('mock_exams').select();
      if (examType != null) {
        query = query.eq('exam_type', examType);
      }
      final response = await query.order('created_at', ascending: false);
      return Result.success(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load exams: $e'));
    }
  }

  @override
  Future<Result<MockExam>> startExam(String examId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.error(AuthFailure('Not authenticated'));
      }

      final response = await _client
          .from('mock_exams')
          .insert({
            'user_id': userId,
            'exam_type': 'IELTS',
            'section': 'Speaking',
            'duration': 60,
          })
          .select()
          .single();

      return Result.success(MockExam.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to start exam: $e'));
    }
  }

  @override
  Future<Result<ExamResult>> submitExam({
    required String attemptId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await _client
          .from('exam_results')
          .insert({
            'exam_id': attemptId,
            'estimated_score': 'Band 7.0',
            'grammar_score': 75,
            'vocabulary_score': 80,
            'fluency_score': 70,
          })
          .select()
          .single();

      return Result.success(ExamResult.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to submit exam: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getHistory(String userId) async {
    try {
      final response = await _client
          .from('mock_exams')
          .select('*, exam_results(*)')
          .eq('user_id', userId)
          .order('started_at', ascending: false);

      return Result.success(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load history: $e'));
    }
  }
}
