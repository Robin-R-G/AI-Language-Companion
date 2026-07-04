import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/achievement.dart';

part 'achievement_providers.g.dart';

@riverpod
class AchievementsList extends _$AchievementsList {
  @override
  AsyncValue<List<Achievement>> build() => const AsyncValue.data([]);

  Future<void> loadAchievements() async {
    state = const AsyncValue.loading();
    final repo = ref.read(achievementRepositoryProvider);
    final result = await repo.getAchievements();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (achievements) => state = AsyncValue.data(achievements),
    );
  }
}

@riverpod
class AchievementsProgress extends _$AchievementsProgress {
  @override
  AsyncValue<List<AchievementProgress>> build() => const AsyncValue.data([]);

  Future<void> loadProgress() async {
    state = const AsyncValue.loading();
    final repo = ref.read(achievementRepositoryProvider);
    final result = await repo.getProgress();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (progress) => state = AsyncValue.data(progress),
    );
  }
}
