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
  Future<Result<List<VocabularyWord>>> getVocabulary(String userId);
  Future<Result<VocabularyWord>> addWord({
    required String userId,
    required String word,
    required String definition,
    String? exampleSentence,
    String? language,
    String? cefrLevel,
    String? category,
  });
}

class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  final SupabaseClient _client;

  VocabularyRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  VocabularyWord _parseVocabularyWord(Map<String, dynamic> json) {
    final exampleSentence = json['example_sentence'] as String?;
    return VocabularyWord(
      id: '${json['id'] ?? ''}',
      word: '${json['word'] ?? ''}',
      meaning: '${json['definition'] ?? ''}',
      pronunciation: '${json['pronunciation'] ?? ''}',
      examples: exampleSentence != null && exampleSentence.isNotEmpty
          ? [exampleSentence]
          : [],
      cefrLevel: '${json['cefr_level'] ?? ''}',
    );
  }

  VocabularyHistory _parseVocabularyHistory(Map<String, dynamic> json) {
    final vocabJson = json['vocabulary'];
    final correctCount = json['correct_count'] as int? ?? 0;
    final incorrectCount = json['incorrect_count'] as int? ?? 0;
    return VocabularyHistory(
      id: '${json['id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      wordId: '${json['vocabulary_id'] ?? ''}',
      masteryLevel: json['mastery_level'] as int? ?? 0,
      reviewCount: correctCount + incorrectCount,
      nextReview: json['next_review_date'] != null
          ? DateTime.tryParse('${json['next_review_date']}')
          : null,
      lastReviewed: json['last_reviewed'] != null
          ? DateTime.tryParse('${json['last_reviewed']}')
          : null,
      word: vocabJson != null
          ? _parseVocabularyWord(Map<String, dynamic>.from(vocabJson as Map))
          : null,
    );
  }

  @override
  Future<Result<List<VocabularyHistory>>> getDailyVocabulary(String userId) async {
    try {
      final response = await _client
          .from('vocabulary_history')
          .select('*, vocabulary(*)')
          .eq('user_id', userId)
          .lte('next_review_date', DateTime.now().toIso8601String())
          .order('next_review_date', ascending: true)
          .limit(20);

      final words = (response as List)
          .map((json) => _parseVocabularyHistory(json as Map<String, dynamic>))
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
      final isCorrect = masteryScore >= 3;
      final existingResponse = await _client
          .from('vocabulary_history')
          .select('correct_count, incorrect_count')
          .eq('user_id', userId)
          .eq('vocabulary_id', wordId)
          .maybeSingle();

      final prevCorrect = existingResponse?['correct_count'] as int? ?? 0;
      final prevIncorrect = existingResponse?['incorrect_count'] as int? ?? 0;

      final response = await _client
          .from('vocabulary_history')
          .upsert({
            'user_id': userId,
            'vocabulary_id': wordId,
            'mastery_level': masteryScore,
            'correct_count': prevCorrect + (isCorrect ? 1 : 0),
            'incorrect_count': prevIncorrect + (isCorrect ? 0 : 1),
            'next_review_date': _calculateNextReview(masteryScore),
            'last_reviewed': DateTime.now().toIso8601String(),
          })
          .select('*, vocabulary(*)')
          .single();

      return Result.success(_parseVocabularyHistory(response));
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
          .map((json) => _parseVocabularyHistory(json as Map<String, dynamic>))
          .toList();

      return Result.success(words);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load history: $e'));
    }
  }

  @override
  Future<Result<List<VocabularyWord>>> getVocabulary(String userId) async {
    try {
      final response = await _client
          .from('vocabulary')
          .select()
          .eq('user_id', userId)
          .order('word', ascending: true);

      final words = (response as List)
          .map((json) => _parseVocabularyWord(json as Map<String, dynamic>))
          .toList();

      return Result.success(words);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load vocabulary list: $e'));
    }
  }

  @override
  Future<Result<VocabularyWord>> addWord({
    required String userId,
    required String word,
    required String definition,
    String? exampleSentence,
    String? language,
    String? cefrLevel,
    String? category,
  }) async {
    try {
      final response = await _client
          .from('vocabulary')
          .insert({
            'user_id': userId,
            'word': word,
            'definition': definition,
            'example_sentence': exampleSentence,
            'language': language,
            'cefr_level': cefrLevel,
            'category': category,
          })
          .select()
          .single();

      return Result.success(_parseVocabularyWord(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to add word: $e'));
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
