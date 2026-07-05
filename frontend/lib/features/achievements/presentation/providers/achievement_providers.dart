import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/achievement.dart';

part 'achievement_providers.g.dart';

@riverpod
class AchievementsList extends _$AchievementsList {
  @override
  AsyncValue<List<Achievement>> build() => const AsyncValue.data([]);

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
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}
