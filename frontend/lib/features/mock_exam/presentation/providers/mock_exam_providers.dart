import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../controllers/mock_exam_controller.dart';
import '../../../../shared/models/exam.dart';

part 'mock_exam_providers.g.dart';

@riverpod
class MockExamsList extends _$MockExamsList {
  @override
  AsyncValue<List<MockExam>> build() => const AsyncValue.data([]);

  Future<void> loadExams({String? examType}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(mockExamRepositoryProvider);
    final result = await repo.getExams(examType: examType);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (exams) => state = AsyncValue.data(exams),
    );
  }
}

@riverpod
class ActiveExam extends _$ActiveExam {
  @override
  AsyncValue<MockExam?> build() => const AsyncValue.data(null);

  Future<void> startExam(String examId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(mockExamRepositoryProvider);
    final result = await repo.startExam(examId);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (exam) => state = AsyncValue.data(exam),
    );
  }

  Future<ExamResult?> submitExam(
    String attemptId,
    List<Map<String, dynamic>> answers,
  ) async {
    final repo = ref.read(mockExamRepositoryProvider);
    final result = await repo.submitExam(
      attemptId: attemptId,
      answers: answers,
    );
    return result.fold((failure) => null, (examResult) => examResult);
  }
}
