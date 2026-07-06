// lib/features/vocabulary/data/datasources/vocabulary_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../shared/models/vocabulary_word.dart';

abstract class VocabularyRemoteDataSource {
  Future<Result<List<VocabularyHistory>>> getDailyVocabulary(String userId);
  Future<Result<VocabularyHistory>> saveReview({
    required String userId,
    required String wordId,
    required int masteryScore,
  });
  Future<Result<List<VocabularyHistory>>> getHistory(String userId);
}

class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  final SupabaseClient _client;

  VocabularyRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<List<VocabularyHistory>>> getDailyVocabulary(String userId) async {
    try {
      final response = await _client
          .from('vocabulary_history')
          .select('*, vocabulary(*)')
          .eq('user_id', userId)
          .lte('next_review', DateTime.now().toIso8601String())
          .order('next_review', ascending: true)
          .limit(20);

      final words = (response as List)
          .map((json) => VocabularyHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(words);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load vocabulary: $e'));
    }
  }

  @override
  Future<Result<VocabularyHistory>> saveReview({
    required String userId,
    required String wordId,
    required int masteryScore,
  }) async {
    try {
      final response = await _client
          .from('vocabulary_history')
          .upsert({
            'user_id': userId,
            'word_id': wordId,
            'mastery_level': masteryScore,
            'review_count': 1,
            'next_review': _calculateNextReview(masteryScore),
            'last_reviewed': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Result.success(VocabularyHistory.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to save review: $e'));
    }
  }

  @override
  Future<Result<List<VocabularyHistory>>> getHistory(String userId) async {
    try {
      final response = await _client
          .from('vocabulary_history')
          .select('*, vocabulary(*)')
          .eq('user_id', userId)
          .order('last_reviewed', ascending: false)
          .limit(100);

      final words = (response as List)
          .map((json) => VocabularyHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(words);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load history: $e'));
    }
  }

  String _calculateNextReview(int masteryScore) {
    final now = DateTime.now();
    switch (masteryScore) {
      case 0:
        return now.add(const Duration(minutes: 10)).toIso8601String();
      case 1:
        return now.add(const Duration(hours: 1)).toIso8601String();
      case 2:
        return now.add(const Duration(hours: 6)).toIso8601String();
      case 3:
        return now.add(const Duration(days: 1)).toIso8601String();
      case 4:
        return now.add(const Duration(days: 3)).toIso8601String();
      default:
        return now.add(const Duration(days: 7)).toIso8601String();
    }
  }
}
