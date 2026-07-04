// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      grammarFeedback: json['grammarFeedback'] == null
          ? null
          : GrammarFeedback.fromJson(
              json['grammarFeedback'] as Map<String, dynamic>,
            ),
      translation: json['translation'] == null
          ? null
          : TranslationData.fromJson(
              json['translation'] as Map<String, dynamic>,
            ),
      tokenCount: (json['tokenCount'] as num?)?.toInt(),
      latencyMs: (json['latencyMs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp?.toIso8601String(),
      'grammarFeedback': instance.grammarFeedback,
      'translation': instance.translation,
      'tokenCount': instance.tokenCount,
      'latencyMs': instance.latencyMs,
    };

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
