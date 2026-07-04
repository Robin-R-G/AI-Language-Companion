// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceSessionImpl _$$VoiceSessionImplFromJson(Map<String, dynamic> json) =>
    _$VoiceSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: json['provider'] as String? ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      roomId: json['roomId'] as String? ?? '',
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      averageLatencyMs: (json['averageLatencyMs'] as num?)?.toInt() ?? 0,
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      transcriptText: json['transcriptText'] as String? ?? '',
    );

Map<String, dynamic> _$$VoiceSessionImplToJson(_$VoiceSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'provider': instance.provider,
      'durationSeconds': instance.durationSeconds,
      'roomId': instance.roomId,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'averageLatencyMs': instance.averageLatencyMs,
      'overallScore': instance.overallScore,
      'transcriptText': instance.transcriptText,
    };

_$PronunciationScoreImpl _$$PronunciationScoreImplFromJson(
  Map<String, dynamic> json,
) => _$PronunciationScoreImpl(
  fluencyScore: (json['fluencyScore'] as num?)?.toInt() ?? 0,
  grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
  vocabularyScore: (json['vocabularyScore'] as num?)?.toInt() ?? 0,
  pronunciationScore: (json['pronunciationScore'] as num?)?.toInt() ?? 0,
  overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
  feedback: json['feedback'] as String? ?? '',
  strengths:
      (json['strengths'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  issues:
      (json['issues'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  practiceWords:
      (json['practiceWords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  shadowingExercise: json['shadowingExercise'] as String? ?? '',
  estimatedProficiency: json['estimatedProficiency'] as String? ?? '',
);

Map<String, dynamic> _$$PronunciationScoreImplToJson(
  _$PronunciationScoreImpl instance,
) => <String, dynamic>{
  'fluencyScore': instance.fluencyScore,
  'grammarScore': instance.grammarScore,
  'vocabularyScore': instance.vocabularyScore,
  'pronunciationScore': instance.pronunciationScore,
  'overallScore': instance.overallScore,
  'feedback': instance.feedback,
  'strengths': instance.strengths,
  'issues': instance.issues,
  'practiceWords': instance.practiceWords,
  'shadowingExercise': instance.shadowingExercise,
  'estimatedProficiency': instance.estimatedProficiency,
};
