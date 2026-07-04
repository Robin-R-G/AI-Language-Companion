import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/reading_passage.dart';

final readingPassagesProvider = FutureProvider.autoDispose<List<ReadingPassage>>((ref) async {
  final repo = ref.watch(readingRepositoryProvider);
  final result = await repo.getPassages();
  if (result.isSuccess) return result.value;
  throw result.failure;
});
