// lib/features/grammar/presentation/controllers/grammar_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> checkGrammar(String text, {String? language}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(grammarRepositoryProvider);
    final result = await repository.checkGrammar(text, language: language);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (grammarResult) => state = AsyncValue.data(grammarResult),
    );
  }

  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

@riverpod
class GrammarRulesController extends _$GrammarRulesController {
  @override
  AsyncValue<List<GrammarRule>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadRules({String? language, String? category}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(grammarRepositoryProvider);
    final result = await repository.fetchGrammarRules(
      language: language,
      category: category,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (rules) => state = AsyncValue.data(rules),
    );
  }
}

@riverpod
class GrammarPracticeController extends _$GrammarPracticeController {
  @override
  AsyncValue<List<GrammarPractice>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadHistory({int limit = 20}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    final repository = ref.read(grammarRepositoryProvider);
    final result = await repository.getPracticeHistory(userId, limit: limit);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (practices) => state = AsyncValue.data(practices),
    );
  }

  Future<void> trackPractice({
    required String ruleId,
    required String originalText,
    required String correctedText,
    required bool isCorrect,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repository = ref.read(grammarRepositoryProvider);
    final result = await repository.trackPractice(
      userId: userId,
      ruleId: ruleId,
      originalText: originalText,
      correctedText: correctedText,
      isCorrect: isCorrect,
    );

    result.fold(
      (failure) => null,
      (practice) {
        final current = state.valueOrNull ?? [];
        state = AsyncValue.data([practice, ...current]);
      },
    );
  }
}
