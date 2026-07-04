import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_session.freezed.dart';
part 'voice_session.g.dart';

@freezed
class VoiceSession with _$VoiceSession {
  const factory VoiceSession({
    required String id,
    required String userId,
    @Default('') String provider,
    @Default(0) int durationSeconds,
    @Default('') String roomId,
    DateTime? startedAt,
    DateTime? endedAt,
    @Default(0) int averageLatencyMs,
    @Default(0) int overallScore,
    @Default('') String transcriptText,
  }) = _VoiceSession;

  factory VoiceSession.fromJson(Map<String, dynamic> json) =>
      _$VoiceSessionFromJson(json);
}

@freezed
class PronunciationScore with _$PronunciationScore {
  const factory PronunciationScore({
    @Default(0) int fluencyScore,
    @Default(0) int grammarScore,
    @Default(0) int vocabularyScore,
    @Default(0) int pronunciationScore,
    @Default(0) int overallScore,
    @Default('') String feedback,
    @Default([]) List<String> strengths,
    @Default([]) List<String> issues,
    @Default([]) List<String> practiceWords,
    @Default('') String shadowingExercise,
    @Default('') String estimatedProficiency,
  }) = _PronunciationScore;

  factory PronunciationScore.fromJson(Map<String, dynamic> json) =>
      _$PronunciationScoreFromJson(json);
}
