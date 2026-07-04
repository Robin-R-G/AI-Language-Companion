import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/grammar_correction.dart';

part 'grammar_providers.g.dart';

@riverpod
class GrammarCheck extends _$GrammarCheck {
  @override
  AsyncValue<GrammarCorrection?> build() => const AsyncValue.data(null);

  Future<void> check(String text, {String? language}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(grammarRepositoryProvider);
    final result = await repo.checkGrammar(text, language: language);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (correction) => state = AsyncValue.data(correction),
    );
  }

  void clear() => state = const AsyncValue.data(null);
}

@riverpod
class GrammarHistory extends _$GrammarHistory {
  @override
  AsyncValue<List<GrammarCorrection>> build() => const AsyncValue.data([]);

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    final repo = ref.read(grammarRepositoryProvider);
    final result = await repo.getHistory();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (history) => state = AsyncValue.data(history),
    );
  }
}
