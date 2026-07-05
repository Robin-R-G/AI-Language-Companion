// lib/shared/models/vocabulary_word.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String id,
    required String word,
    required String meaning,
    required String pronunciation,
    required List<String> examples,
    required String cefrLevel,
    String? meaningMalayalam,
    String? synonyms,
    String? antonyms,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) =>
      _$VocabularyWordFromJson(json);
}

@freezed
class VocabularyHistory with _$VocabularyHistory {
  const factory VocabularyHistory({
    required String id,
    required String userId,
    required String wordId,
    @Default(0) int masteryLevel,
    @Default(0) int reviewCount,
    DateTime? nextReview,
    DateTime? lastReviewed,
    VocabularyWord? word,
  }) = _VocabularyHistory;

  factory VocabularyHistory.fromJson(Map<String, dynamic> json) =>
      _$VocabularyHistoryFromJson(json);
}
