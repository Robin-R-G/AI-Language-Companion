// lib/features/achievements/presentation/controllers/achievements_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/gamification.dart';

part 'achievements_controller.g.dart';

@riverpod
class AchievementsController extends _$AchievementsController {
  @override
  AsyncValue<List<Achievement>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadAchievements() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .order('unlocked_at', ascending: false);

      final achievements = (response as List)
          .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(achievements);
    } catch (e) {
      state = AsyncValue.error('Failed to load achievements: $e', StackTrace.current);
    }
  }

  Future<void> claimAchievement(String achievementId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // In a real implementation, this would call an edge function
      // that verifies the achievement criteria and awards XP
      await loadAchievements();
    } catch (e) {
      state = AsyncValue.error('Failed to claim: $e', StackTrace.current);
    }
  }
}
