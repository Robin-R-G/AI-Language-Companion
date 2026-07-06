import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/grammar_correction.dart';
import '../../data/datasources/grammar_remote_datasource.dart';

part 'grammar_providers.g.dart';

@riverpod
class GrammarCheck extends _$GrammarCheck {
  @override
  AsyncValue<GrammarResult?> build() => const AsyncValue.data(null);

  Future<void> check(String text, {String? languageLevel, String? nativeLanguage}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(grammarRepositoryProvider);
    final result = await repo.checkGrammar(
      text,
      languageLevel: languageLevel,
      nativeLanguage: nativeLanguage,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (correction) => state = AsyncValue.data(correction),
    );
  }

  void clear() => state = const AsyncValue.data(null);
}
