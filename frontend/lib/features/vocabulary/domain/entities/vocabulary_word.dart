import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

@freezed
abstract class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String id,
    required String word,
    required String meaning,
    required String pronunciation,
    required List<String> examples,
    required String cefrLevel,
    required String partOfSpeech,
    required String targetLanguage,
    required String nativeLanguage,
    required String? audioUrl,
    required String? imageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) =>
      _$VocabularyWordFromJson(json);
}

@freezed
abstract class VocabularyProgress with _$VocabularyProgress {
  const factory VocabularyProgress({
    required String userId,
    required String vocabularyId,
    required int masteryLevel,
    required int reviewCount,
    required DateTime nextReview,
    required DateTime lastReviewed,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VocabularyProgress;

  factory VocabularyProgress.fromJson(Map<String, dynamic> json) =>
      _$VocabularyProgressFromJson(json);
}