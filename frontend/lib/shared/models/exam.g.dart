// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamImpl _$$MockExamImplFromJson(Map<String, dynamic> json) =>
    _$MockExamImpl(
      id: json['id'] as String,
      examType: json['examType'] as String,
      section: json['section'] as String,
      duration: (json['duration'] as num).toInt(),
      title: json['title'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$MockExamImplToJson(_$MockExamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examType': instance.examType,
      'section': instance.section,
      'duration': instance.duration,
      'title': instance.title,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$ExamResultImpl _$$ExamResultImplFromJson(Map<String, dynamic> json) =>
    _$ExamResultImpl(
      id: json['id'] as String,
      examId: json['examId'] as String,
      estimatedScore: json['estimatedScore'] as String,
      grammarScore: (json['grammarScore'] as num?)?.toInt(),
      vocabularyScore: (json['vocabularyScore'] as num?)?.toInt(),
      fluencyScore: (json['fluencyScore'] as num?)?.toInt(),
      recommendations: json['recommendations'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ExamResultImplToJson(_$ExamResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examId': instance.examId,
      'estimatedScore': instance.estimatedScore,
      'grammarScore': instance.grammarScore,
      'vocabularyScore': instance.vocabularyScore,
      'fluencyScore': instance.fluencyScore,
      'recommendations': instance.recommendations,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$VoiceSessionImpl _$$VoiceSessionImplFromJson(Map<String, dynamic> json) =>
    _$VoiceSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: json['provider'] as String,
      duration: (json['duration'] as num).toInt(),
      roomId: json['roomId'] as String,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
    );

Map<String, dynamic> _$$VoiceSessionImplToJson(_$VoiceSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'provider': instance.provider,
      'duration': instance.duration,
      'roomId': instance.roomId,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
    };

_$VoiceTranscriptImpl _$$VoiceTranscriptImplFromJson(
  Map<String, dynamic> json,
) => _$VoiceTranscriptImpl(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  transcript: json['transcript'] as String,
  aiResponse: json['aiResponse'] as String,
  pronunciationScore: (json['pronunciationScore'] as num?)?.toInt(),
  fluencyScore: (json['fluencyScore'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$VoiceTranscriptImplToJson(
  _$VoiceTranscriptImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'transcript': instance.transcript,
  'aiResponse': instance.aiResponse,
  'pronunciationScore': instance.pronunciationScore,
  'fluencyScore': instance.fluencyScore,
  'createdAt': instance.createdAt?.toIso8601String(),
};
