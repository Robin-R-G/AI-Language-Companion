// lib/features/home/data/datasources/dashboard_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

class DashboardData {
  final int xp;
  final int level;
  final int streak;
  final List<Map<String, dynamic>> weeklyProgress;
  final Map<String, int> skills;
  final List<String> recommendations;
  final int todayMinutes;
  final int lessonsCompleted;
  final int wordsLearned;

  const DashboardData({
    required this.xp,
    required this.level,
    required this.streak,
    required this.weeklyProgress,
    required this.skills,
    required this.recommendations,
    required this.todayMinutes,
    required this.lessonsCompleted,
    required this.wordsLearned,
  });
}

abstract class DashboardRemoteDataSource {
  Future<Result<DashboardData>> getDashboard(String userId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient _client;

  DashboardRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<DashboardData>> getDashboard(String userId) async {
    try {
      final results = await Future.wait([
        _client.from('user_progress').select().eq('user_id', userId).maybeSingle(),
        _client.from('streaks').select().eq('user_id', userId).maybeSingle(),
        _client.from('user_profiles').select().eq('auth_user_id', userId).maybeSingle(),
        _client.from('vocabulary_history')
            .select()
            .eq('user_id', userId)
            .gte('next_review', DateTime.now().toIso8601String())
            .limit(5),
        _client.from('lesson_progress')
            .select()
            .eq('user_id', userId)
            .gte('started_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String()),
      ]);

      final progress = results[0] as Map<String, dynamic>?;
      final streak = results[1] as Map<String, dynamic>?;
      final profile = results[2] as Map<String, dynamic>?;
      final vocabulary = results[3] as List<dynamic>;
      final lessons = results[4] as List<dynamic>;

      final totalWeeklyMinutes = lessons.fold<int>(
        0,
        (sum, l) => sum + ((l['completion_percentage'] ?? 0) as num).toInt(),
      );

      return Result.success(DashboardData(
        xp: (progress?['xp'] as num?)?.toInt() ?? 0,
        level: (progress?['level'] as num?)?.toInt() ?? 1,
        streak: (streak?['current_streak'] as num?)?.toInt() ?? 0,
        weeklyProgress: _buildWeeklyProgress(lessons),
        skills: {
          'grammar': (progress?['grammar_score'] as num?)?.toInt() ?? 0,
          'speaking': (progress?['speaking_score'] as num?)?.toInt() ?? 0,
          'writing': (progress?['writing_score'] as num?)?.toInt() ?? 0,
          'vocabulary': (progress?['vocabulary_score'] as num?)?.toInt() ?? 0,
          'reading': (progress?['reading_score'] as num?)?.toInt() ?? 0,
          'listening': (progress?['listening_score'] as num?)?.toInt() ?? 0,
        },
        recommendations: _buildRecommendations(progress),
        todayMinutes: totalWeeklyMinutes,
        lessonsCompleted: lessons.length,
        wordsLearned: vocabulary.length,
      ));
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load dashboard: $e'));
    }
  }

  List<Map<String, dynamic>> _buildWeeklyProgress(List<dynamic> lessons) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = day.toIso8601String().substring(0, 10);
      final dayLessons = lessons.where((l) =>
          l['started_at']?.toString().startsWith(dayStr) == true);
      final minutes = dayLessons.fold<int>(
        0,
        (sum, l) => sum + ((l['completion_percentage'] ?? 0) as num).toInt(),
      );
      return {'day': days[i], 'minutes': minutes};
    });
  }

  List<String> _buildRecommendations(Map<String, dynamic>? progress) {
    final recommendations = <String>[];
    if (progress == null) return ['Start your first lesson!'];

    if (((progress['grammar_score'] as num?) ?? 0) < 50) {
      recommendations.add('Review grammar fundamentals');
    }
    if (((progress['vocabulary_score'] as num?) ?? 0) < 50) {
      recommendations.add('Practice daily vocabulary');
    }
    if (((progress['speaking_score'] as num?) ?? 0) < 50) {
      recommendations.add('Try a speaking session');
    }
    if (((progress['writing_score'] as num?) ?? 0) < 50) {
      recommendations.add('Write a short essay');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Keep up the great work!');
    }

    return recommendations;
  }
}
