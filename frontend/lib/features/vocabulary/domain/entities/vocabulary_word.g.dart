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
      partOfSpeech: json['partOfSpeech'] as String,
      targetLanguage: json['targetLanguage'] as String,
      nativeLanguage: json['nativeLanguage'] as String,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
  'partOfSpeech': instance.partOfSpeech,
  'targetLanguage': instance.targetLanguage,
  'nativeLanguage': instance.nativeLanguage,
  'audioUrl': instance.audioUrl,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$VocabularyProgressImpl _$$VocabularyProgressImplFromJson(
  Map<String, dynamic> json,
) => _$VocabularyProgressImpl(
  userId: json['userId'] as String,
  vocabularyId: json['vocabularyId'] as String,
  masteryLevel: (json['masteryLevel'] as num).toInt(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  nextReview: DateTime.parse(json['nextReview'] as String),
  lastReviewed: DateTime.parse(json['lastReviewed'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$VocabularyProgressImplToJson(
  _$VocabularyProgressImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'vocabularyId': instance.vocabularyId,
  'masteryLevel': instance.masteryLevel,
  'reviewCount': instance.reviewCount,
  'nextReview': instance.nextReview.toIso8601String(),
  'lastReviewed': instance.lastReviewed.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
