// lib/features/writing/presentation/controllers/writing_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/writing_remote_datasource.dart';
import '../../data/repositories/writing_repository_impl.dart';

part 'writing_controller.g.dart';

@riverpod
WritingRepository writingRepository(WritingRepositoryRef ref) {
  return WritingRepositoryImpl();
}

@riverpod
class WritingController extends _$WritingController {
  @override
  AsyncValue<WritingEvaluation?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> evaluateEssay(String essayText) async {
    state = const AsyncValue.loading();
    final repository = ref.read(writingRepositoryProvider);
    final result = await repository.evaluateEssay(essayText);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (evaluation) => state = AsyncValue.data(evaluation),
    );
  }

  void clearResult() {
    state = const AsyncValue.data(null);
  }
}
