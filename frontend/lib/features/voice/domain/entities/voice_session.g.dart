// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceSessionImpl _$$VoiceSessionImplFromJson(Map<String, dynamic> json) =>
    _$VoiceSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionType: json['sessionType'] as String,
      targetLanguage: json['targetLanguage'] as String,
      topic: json['topic'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      xpEarned: (json['xpEarned'] as num).toInt(),
      status: json['status'] as String,
      liveKitRoomName: json['liveKitRoomName'] as String?,
      recordingUrl: json['recordingUrl'] as String?,
      transcript: json['transcript'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VoiceSessionImplToJson(_$VoiceSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sessionType': instance.sessionType,
      'targetLanguage': instance.targetLanguage,
      'topic': instance.topic,
      'durationMinutes': instance.durationMinutes,
      'xpEarned': instance.xpEarned,
      'status': instance.status,
      'liveKitRoomName': instance.liveKitRoomName,
      'recordingUrl': instance.recordingUrl,
      'transcript': instance.transcript,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$PronunciationScoreImpl _$$PronunciationScoreImplFromJson(
  Map<String, dynamic> json,
) => _$PronunciationScoreImpl(
  sessionId: json['sessionId'] as String,
  userId: json['userId'] as String,
  overallScore: (json['overallScore'] as num).toDouble(),
  fluency: (json['fluency'] as num).toDouble(),
  clarity: (json['clarity'] as num).toDouble(),
  stress: (json['stress'] as num).toDouble(),
  intonation: (json['intonation'] as num).toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
  wordScores: (json['wordScores'] as List<dynamic>)
      .map((e) => WordScore.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$PronunciationScoreImplToJson(
  _$PronunciationScoreImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'userId': instance.userId,
  'overallScore': instance.overallScore,
  'fluency': instance.fluency,
  'clarity': instance.clarity,
  'stress': instance.stress,
  'intonation': instance.intonation,
  'confidence': instance.confidence,
  'wordScores': instance.wordScores,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$WordScoreImpl _$$WordScoreImplFromJson(Map<String, dynamic> json) =>
    _$WordScoreImpl(
      word: json['word'] as String,
      score: (json['score'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$WordScoreImplToJson(_$WordScoreImpl instance) =>
    <String, dynamic>{
      'word': instance.word,
      'score': instance.score,
      'status': instance.status,
    };
