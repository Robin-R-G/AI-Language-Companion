import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/mock_exam.dart';

part 'mock_exam_providers.g.dart';

@riverpod
class MockExamsList extends _$MockExamsList {
  @override
  AsyncValue<List<MockExam>> build() => const AsyncValue.data([]);

  Future<void> loadExams({String? examType, String? section}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(mockExamRepositoryProvider);
    final result = await repo.getExams(examType: examType, section: section);
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

  Future<void> submitAnswer(
    String examId,
    String questionId,
    String answer,
  ) async {
    final repo = ref.read(mockExamRepositoryProvider);
    final result = await repo.submitAnswer(examId, questionId, answer);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {},
    );
  }

  Future<void> completeExam(String examId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(mockExamRepositoryProvider);
    final result = await repo.completeExam(examId);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (exam) => state = AsyncValue.data(exam),
    );
  }
}
