import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/writing_prompt.dart';

final writingPromptsProvider = FutureProvider.autoDispose<List<WritingPrompt>>((ref) async {
  final repo = ref.watch(writingRepositoryProvider);
  final result = await repo.getPrompts();
  return result.fold((f) => throw f, (v) => v);
});
