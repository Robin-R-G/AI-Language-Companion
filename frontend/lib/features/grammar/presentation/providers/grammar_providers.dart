import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/grammar_correction.dart';
import '../../data/datasources/grammar_remote_datasource.dart';

part 'grammar_providers.g.dart';

@riverpod
class GrammarCheck extends _$GrammarCheck {
  @override
  AsyncValue<GrammarResult?> build() => const AsyncValue.data(null);

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
class GrammarRules extends _$GrammarRules {
  @override
  AsyncValue<List<GrammarRule>> build() => const AsyncValue.data([]);

  Future<void> load({String? language, String? category}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(grammarRepositoryProvider);
    final result = await repo.fetchGrammarRules(
      language: language,
      category: category,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (rules) => state = AsyncValue.data(rules),
    );
  }
}

@riverpod
class GrammarPracticeHistory extends _$GrammarPracticeHistory {
  @override
  AsyncValue<List<GrammarPractice>> build() => const AsyncValue.data([]);

  Future<void> load({int limit = 20}) async {
    state = const AsyncValue.loading();
    final repo = ref.read(grammarRepositoryProvider);
    final result = await repo.getPracticeHistory(
      Supabase.instance.client.auth.currentUser?.id ?? '',
      limit: limit,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (practices) => state = AsyncValue.data(practices),
    );
  }
}
