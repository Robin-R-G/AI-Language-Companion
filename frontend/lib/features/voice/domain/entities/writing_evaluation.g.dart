// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_evaluation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WritingEvaluationImpl _$$WritingEvaluationImplFromJson(
  Map<String, dynamic> json,
) => _$WritingEvaluationImpl(
  estimatedBand: json['estimatedBand'] as String? ?? '',
  grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
  vocabularyScore: (json['vocabularyScore'] as num?)?.toInt() ?? 0,
  organizationScore: (json['organizationScore'] as num?)?.toInt() ?? 0,
  clarityScore: (json['clarityScore'] as num?)?.toInt() ?? 0,
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  mistakes:
      (json['mistakes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  improvedVersion: json['improvedVersion'] as String? ?? '',
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$WritingEvaluationImplToJson(
  _$WritingEvaluationImpl instance,
) => <String, dynamic>{
  'estimatedBand': instance.estimatedBand,
  'grammarScore': instance.grammarScore,
  'vocabularyScore': instance.vocabularyScore,
  'organizationScore': instance.organizationScore,
  'clarityScore': instance.clarityScore,
  'strengths': instance.strengths,
  'mistakes': instance.mistakes,
  'improvedVersion': instance.improvedVersion,
  'recommendations': instance.recommendations,
};
