import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/writing_prompt.dart';

final writingPromptsProvider = FutureProvider.autoDispose<List<WritingPrompt>>((ref) async {
  final repo = ref.watch(writingRepositoryProvider);
  final result = await repo.getPrompts();
  if (result.isSuccess) return result.value;
  throw result.failure;
});
