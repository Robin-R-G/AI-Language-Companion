import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_session.freezed.dart';
part 'voice_session.g.dart';

@freezed
abstract class VoiceSession with _$VoiceSession {
  const factory VoiceSession({
    required String id,
    required String userId,
    required String sessionType,
    required String targetLanguage,
    required String topic,
    required int durationMinutes,
    required int xpEarned,
    required String status,
    String? liveKitRoomName,
    String? recordingUrl,
    String? transcript,
    required DateTime startedAt,
    DateTime? endedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VoiceSession;

  factory VoiceSession.fromJson(Map<String, dynamic> json) =>
      _$VoiceSessionFromJson(json);
}

@freezed
abstract class PronunciationScore with _$PronunciationScore {
  const factory PronunciationScore({
    required String sessionId,
    required String userId,
    required double overallScore,
    required double fluency,
    required double clarity,
    required double stress,
    required double intonation,
    required double confidence,
    required List<WordScore> wordScores,
    required DateTime createdAt,
  }) = _PronunciationScore;

  factory PronunciationScore.fromJson(Map<String, dynamic> json) =>
      _$PronunciationScoreFromJson(json);
}

@freezed
abstract class WordScore with _$WordScore {
  const factory WordScore({
    required String word,
    required double score,
    required String status,
  }) = _WordScore;

  factory WordScore.fromJson(Map<String, dynamic> json) =>
      _$WordScoreFromJson(json);
}