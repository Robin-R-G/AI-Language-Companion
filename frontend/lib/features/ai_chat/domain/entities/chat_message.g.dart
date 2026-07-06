// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GrammarFeedbackImpl _$$GrammarFeedbackImplFromJson(
  Map<String, dynamic> json,
) => _$GrammarFeedbackImpl(
  isCorrect: json['isCorrect'] as bool? ?? false,
  original: json['original'] as String,
  corrected: json['corrected'] as String,
  explanation: json['explanation'] as String,
  explanationMalayalam: json['explanationMalayalam'] as String? ?? '',
  category: json['category'] as String? ?? '',
  examples:
      (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$GrammarFeedbackImplToJson(
  _$GrammarFeedbackImpl instance,
) => <String, dynamic>{
  'isCorrect': instance.isCorrect,
  'original': instance.original,
  'corrected': instance.corrected,
  'explanation': instance.explanation,
  'explanationMalayalam': instance.explanationMalayalam,
  'category': instance.category,
  'examples': instance.examples,
};

_$TranslationDataImpl _$$TranslationDataImplFromJson(
  Map<String, dynamic> json,
) => _$TranslationDataImpl(
  translation: json['translation'] as String,
  pronunciation: json['pronunciation'] as String? ?? '',
  alternativeExpressions:
      (json['alternativeExpressions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
  explanation: json['explanation'] as String? ?? '',
);

Map<String, dynamic> _$$TranslationDataImplToJson(
  _$TranslationDataImpl instance,
) => <String, dynamic>{
  'translation': instance.translation,
  'pronunciation': instance.pronunciation,
  'alternativeExpressions': instance.alternativeExpressions,
  'explanation': instance.explanation,
};
