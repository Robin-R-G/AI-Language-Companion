// lib/features/progress/presentation/controllers/progress_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/user_profile.dart';

part 'progress_controller.g.dart';

@riverpod
class ProgressDashboardController extends _$ProgressDashboardController {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadProgress() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    try {
      final results = await Future.wait([
        Supabase.instance.client
            .from('user_progress')
            .select()
            .eq('user_id', userId)
            .maybeSingle(),
        Supabase.instance.client
            .from('lesson_progress')
            .select()
            .eq('user_id', userId)
            .gte('started_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String()),
        Supabase.instance.client
            .from('vocabulary_history')
            .select()
            .eq('user_id', userId),
        Supabase.instance.client
            .from('voice_sessions')
            .select()
            .eq('user_id', userId),
      ]);

      final progress = results[0] as Map<String, dynamic>?;
      final lessons = results[1] as List;
      final vocabulary = results[2] as List;
      final voiceSessions = results[3] as List;

      state = AsyncValue.data({
        'progress': progress,
        'lessons_completed': lessons.length,
        'total_xp': progress?['xp'] ?? 0,
        'level': progress?['level'] ?? 1,
        'vocabulary_learned': vocabulary.length,
        'voice_sessions': voiceSessions.length,
        'skills': {
          'grammar': progress?['grammar_score'] ?? 0,
          'speaking': progress?['speaking_score'] ?? 0,
          'writing': progress?['writing_score'] ?? 0,
          'vocabulary': progress?['vocabulary_score'] ?? 0,
          'reading': progress?['reading_score'] ?? 0,
          'listening': progress?['listening_score'] ?? 0,
        },
      });
    } catch (e) {
      state = AsyncValue.error('Failed to load progress: $e', StackTrace.current);
    }
  }
}
