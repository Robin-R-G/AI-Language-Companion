// lib/features/grammar/presentation/controllers/grammar_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/grammar_remote_datasource.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../../../../core/providers/repository_providers.dart';

part 'grammar_controller.g.dart';

@riverpod
class GrammarController extends _$GrammarController {
  @override
  AsyncValue<GrammarResult?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> checkGrammar(String text, {
    String? languageLevel,
    String? nativeLanguage,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(grammarRepositoryProvider);
    final result = await repository.checkGrammar(
      text,
      languageLevel: languageLevel,
      nativeLanguage: nativeLanguage,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (grammarResult) => state = AsyncValue.data(grammarResult),
    );
  }

  void clearResult() {
    state = const AsyncValue.data(null);
  }
}
