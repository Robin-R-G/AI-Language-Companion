import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/reading_passage.dart';

final readingPassagesProvider = FutureProvider.autoDispose<List<ReadingPassage>>((ref) async {
  final repo = ref.watch(readingRepositoryProvider);
  final result = await repo.getPassages();
  return result.fold(
    (failure) => throw failure,
    (passages) => passages,
  );
});
