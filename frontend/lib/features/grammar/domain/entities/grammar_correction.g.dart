// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_correction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GrammarCorrectionImpl _$$GrammarCorrectionImplFromJson(
  Map<String, dynamic> json,
) => _$GrammarCorrectionImpl(
  id: json['id'] as String,
  originalText: json['originalText'] as String,
  correctedText: json['correctedText'] as String,
  explanation: json['explanation'] as String,
  explanationMalayalam: json['explanationMalayalam'] as String? ?? '',
  category: json['category'] as String? ?? '',
  severity: json['severity'] as String? ?? 'medium',
  suggestions:
      (json['suggestions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  relatedRules:
      (json['relatedRules'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  startIndex: (json['startIndex'] as num?)?.toInt() ?? 0,
  endIndex: (json['endIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$GrammarCorrectionImplToJson(
  _$GrammarCorrectionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'originalText': instance.originalText,
  'correctedText': instance.correctedText,
  'explanation': instance.explanation,
  'explanationMalayalam': instance.explanationMalayalam,
  'category': instance.category,
  'severity': instance.severity,
  'suggestions': instance.suggestions,
  'relatedRules': instance.relatedRules,
  'createdAt': instance.createdAt?.toIso8601String(),
  'startIndex': instance.startIndex,
  'endIndex': instance.endIndex,
};
