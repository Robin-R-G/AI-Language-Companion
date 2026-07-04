import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_word.freezed.dart';
part 'vocabulary_word.g.dart';

@freezed
class VocabularyWord with _$VocabularyWord {
  const factory VocabularyWord({
    required String id,
    required String word,
    required String meaning,
    @Default('') String meaningMalayalam,
    @Default('') String pronunciation,
    @Default([]) List<String> examples,
    @Default('') String cefrLevel,
    @Default(0) int masteryLevel,
    @Default(0) int reviewCount,
    DateTime? nextReview,
    DateTime? lastReviewed,
  }) = _VocabularyWord;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) =>
      _$VocabularyWordFromJson(json);
}
