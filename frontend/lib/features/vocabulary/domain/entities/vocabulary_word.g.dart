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
      meaningMalayalam: json['meaningMalayalam'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cefrLevel: json['cefrLevel'] as String? ?? '',
      masteryLevel: (json['masteryLevel'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      nextReview: json['nextReview'] == null
          ? null
          : DateTime.parse(json['nextReview'] as String),
      lastReviewed: json['lastReviewed'] == null
          ? null
          : DateTime.parse(json['lastReviewed'] as String),
    );

Map<String, dynamic> _$$VocabularyWordImplToJson(
  _$VocabularyWordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'word': instance.word,
  'meaning': instance.meaning,
  'meaningMalayalam': instance.meaningMalayalam,
  'pronunciation': instance.pronunciation,
  'examples': instance.examples,
  'cefrLevel': instance.cefrLevel,
  'masteryLevel': instance.masteryLevel,
  'reviewCount': instance.reviewCount,
  'nextReview': instance.nextReview?.toIso8601String(),
  'lastReviewed': instance.lastReviewed?.toIso8601String(),
};
