// lib/features/mock_exam/presentation/controllers/mock_exam_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/mock_exam_remote_datasource.dart';
import '../../data/repositories/mock_exam_repository_impl.dart';
import '../../../../shared/models/exam.dart';
import '../../domain/repositories/mock_exam_repository.dart';

part 'mock_exam_controller.g.dart';

@riverpod
MockExamRepository mockExamRepository(MockExamRepositoryRef ref) {
  return MockExamRepositoryImpl();
}

@riverpod
class MockExamController extends _$MockExamController {
  @override
  AsyncValue<List<MockExam>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadExams({String? examType}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(mockExamRepositoryProvider);
    final result = await repository.getExams(examType: examType);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (exams) => state = AsyncValue.data(exams),
    );
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    final repository = ref.read(mockExamRepositoryProvider);
    final result = await repository.getHistory(userId);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (history) => state = AsyncValue.data(history),
    );
  }
}

@riverpod
class ExamSessionController extends _$ExamSessionController {
  String? _attemptId;

  @override
  AsyncValue<MockExam?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> startExam(String examId) async {
    state = const AsyncValue.loading();
    final repository = ref.read(mockExamRepositoryProvider);
    final result = await repository.startExam(examId);

    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (exam) {
        _attemptId = exam.id;
        state = AsyncValue.data(exam);
      },
    );
  }

  Future<ExamResult?> submitExam(List<Map<String, dynamic>> answers) async {
    if (_attemptId == null) return null;

    final repository = ref.read(mockExamRepositoryProvider);
    final result = await repository.submitExam(
      attemptId: _attemptId!,
      answers: answers,
    );

    return result.fold((failure) => null, (examResult) => examResult);
  }
}
