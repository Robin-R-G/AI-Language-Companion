// lib/shared/models/exam.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@freezed
class MockExam with _$MockExam {
  const factory MockExam({
    required String id,
    required String examType,
    required String section,
    required int duration,
    String? title,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _MockExam;

  factory MockExam.fromJson(Map<String, dynamic> json) =>
      _$MockExamFromJson(json);
}

@freezed
class ExamResult with _$ExamResult {
  const factory ExamResult({
    required String id,
    required String examId,
    required String estimatedScore,
    int? grammarScore,
    int? vocabularyScore,
    int? fluencyScore,
    String? recommendations,
    DateTime? createdAt,
  }) = _ExamResult;

  factory ExamResult.fromJson(Map<String, dynamic> json) =>
      _$ExamResultFromJson(json);
}

@freezed
class VoiceSession with _$VoiceSession {
  const factory VoiceSession({
    required String id,
    required String userId,
    required String provider,
    required int duration,
    required String roomId,
    DateTime? startedAt,
    DateTime? endedAt,
  }) = _VoiceSession;

  factory VoiceSession.fromJson(Map<String, dynamic> json) =>
      _$VoiceSessionFromJson(json);
}

@freezed
class VoiceTranscript with _$VoiceTranscript {
  const factory VoiceTranscript({
    required String id,
    required String sessionId,
    required String transcript,
    required String aiResponse,
    int? pronunciationScore,
    int? fluencyScore,
    DateTime? createdAt,
  }) = _VoiceTranscript;

  factory VoiceTranscript.fromJson(Map<String, dynamic> json) =>
      _$VoiceTranscriptFromJson(json);
}
