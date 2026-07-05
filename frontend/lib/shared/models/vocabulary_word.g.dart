// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VocabularyWordImpl _$$VocabularyWordImplFromJson(Map<String, dynamic> json) =>
    _$VocabularyWordImpl(
      id: json['id'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      pronunciation: json['pronunciation'] as String,
      examples: (json['examples'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      cefrLevel: json['cefrLevel'] as String,
      meaningMalayalam: json['meaningMalayalam'] as String?,
      synonyms: json['synonyms'] as String?,
      antonyms: json['antonyms'] as String?,
    );

Map<String, dynamic> _$$VocabularyWordImplToJson(
  _$VocabularyWordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'word': instance.word,
  'meaning': instance.meaning,
  'pronunciation': instance.pronunciation,
  'examples': instance.examples,
  'cefrLevel': instance.cefrLevel,
  'meaningMalayalam': instance.meaningMalayalam,
  'synonyms': instance.synonyms,
  'antonyms': instance.antonyms,
};

_$VocabularyHistoryImpl _$$VocabularyHistoryImplFromJson(
  Map<String, dynamic> json,
) => _$VocabularyHistoryImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  wordId: json['wordId'] as String,
  masteryLevel: (json['masteryLevel'] as num?)?.toInt() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  nextReview: json['nextReview'] == null
      ? null
      : DateTime.parse(json['nextReview'] as String),
  lastReviewed: json['lastReviewed'] == null
      ? null
      : DateTime.parse(json['lastReviewed'] as String),
  word: json['word'] == null
      ? null
      : VocabularyWord.fromJson(json['word'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$VocabularyHistoryImplToJson(
  _$VocabularyHistoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'wordId': instance.wordId,
  'masteryLevel': instance.masteryLevel,
  'reviewCount': instance.reviewCount,
  'nextReview': instance.nextReview?.toIso8601String(),
  'lastReviewed': instance.lastReviewed?.toIso8601String(),
  'word': instance.word,
};
