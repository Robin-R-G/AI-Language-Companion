// lib/features/grammar/data/datasources/grammar_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';

class GrammarRule {
  final String id;
  final String ruleName;
  final String description;
  final String category;
  final String language;
  final List<String> examples;
  final String cefrLevel;
  final int difficulty;
  final String userId;

  const GrammarRule({
    required this.id,
    required this.ruleName,
    required this.description,
    required this.category,
    required this.language,
    required this.examples,
    required this.cefrLevel,
    required this.difficulty,
    required this.userId,
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      id: json['id'] as String? ?? '',
      ruleName: json['rule_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      examples: (json['examples'] as List<dynamic>?)?.cast<String>() ?? [],
      cefrLevel: json['cefr_level'] as String? ?? 'A1',
      difficulty: json['difficulty'] as int? ?? 1,
      userId: json['user_id'] as String? ?? '',
    );
  }
}

class GrammarResult {
  final bool isCorrect;
  final String original;
  final String corrected;
  final String explanation;
  final String explanationMalayalam;
  final String category;
  final List<String> examples;
  final String? ruleName;

  const GrammarResult({
    required this.isCorrect,
    required this.original,
    required this.corrected,
    required this.explanation,
    required this.explanationMalayalam,
    required this.category,
    required this.examples,
    this.ruleName,
  });

  factory GrammarResult.fromJson(Map<String, dynamic> json) {
    return GrammarResult(
      isCorrect: (json['is_correct'] as bool?) ?? true,
      original: (json['original'] as String?) ?? '',
      corrected: (json['corrected'] as String?) ?? '',
      explanation: (json['explanation'] as String?) ?? '',
      explanationMalayalam: (json['explanation_malayalam'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'General',
      examples: (json['examples'] as List<dynamic>?)?.cast<String>() ?? [],
      ruleName: json['rule_name'] as String?,
    );
  }
}

class GrammarPractice {
  final String id;
  final String userId;
  final String ruleId;
  final String originalText;
  final String correctedText;
  final bool isCorrect;
  final DateTime createdAt;

  const GrammarPractice({
    required this.id,
    required this.userId,
    required this.ruleId,
    required this.originalText,
    required this.correctedText,
    required this.isCorrect,
    required this.createdAt,
  });

  factory GrammarPractice.fromJson(Map<String, dynamic> json) {
    return GrammarPractice(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      ruleId: json['rule_id'] as String? ?? '',
      originalText: json['original_text'] as String? ?? '',
      correctedText: json['corrected_text'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

abstract class GrammarRemoteDataSource {
  Future<Result<List<GrammarRule>>> fetchGrammarRules({String? language, String? category});
  Future<Result<GrammarResult>> checkGrammar(String text, {String? language});
  Future<Result<List<GrammarPractice>>> getPracticeHistory(String userId, {int limit = 20});
  Future<Result<GrammarPractice>> trackPractice({
    required String userId,
    required String ruleId,
    required String originalText,
    required String correctedText,
    required bool isCorrect,
  });
}

class GrammarRemoteDataSourceImpl implements GrammarRemoteDataSource {
  final SupabaseClient _client;

  GrammarRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Result<List<GrammarRule>>> fetchGrammarRules({
    String? language,
    String? category,
  }) async {
    try {
      var query = _client.from('grammar_rules').select();

      if (language != null) {
        query = query.eq('language', language);
      }
      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('created_at', ascending: false);

      final rules = (response as List)
          .map((json) => GrammarRule.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(rules);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load grammar rules: $e'));
    }
  }

  @override
  Future<Result<GrammarResult>> checkGrammar(String text, {String? language}) async {
    try {
      final response = await _client.functions.invoke(
        'grammar-check',
        body: {
          'text': text,
          if (language != null) 'language': language,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return Result.success(
            GrammarResult.fromJson(data['data'] as Map<String, dynamic>),
          );
        }
        return Result.error(
          ServerFailure(data['message'] as String? ?? 'Grammar check failed'),
        );
      }

      return Result.error(ServerFailure('Grammar check failed with status ${response.status}'));
    } catch (e) {
      return Result.error(NetworkFailure('Grammar check failed: $e'));
    }
  }

  @override
  Future<Result<List<GrammarPractice>>> getPracticeHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('grammar_practice')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final practices = (response as List)
          .map((json) => GrammarPractice.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(practices);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load practice history: $e'));
    }
  }

  @override
  Future<Result<GrammarPractice>> trackPractice({
    required String userId,
    required String ruleId,
    required String originalText,
    required String correctedText,
    required bool isCorrect,
  }) async {
    try {
      final response = await _client
          .from('grammar_practice')
          .insert({
            'user_id': userId,
            'rule_id': ruleId,
            'original_text': originalText,
            'corrected_text': correctedText,
            'is_correct': isCorrect,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Result.success(
        GrammarPractice.fromJson(response as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to track practice: $e'));
    }
  }
}
