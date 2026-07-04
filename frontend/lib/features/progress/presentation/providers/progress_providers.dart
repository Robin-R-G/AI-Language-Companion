import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/progress_stats.dart';

final progressStatsProvider = FutureProvider.autoDispose<ProgressStats>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final result = await repo.getStats();
  return result.fold(
    (failure) => throw failure,
    (stats) => stats,
  );
});
