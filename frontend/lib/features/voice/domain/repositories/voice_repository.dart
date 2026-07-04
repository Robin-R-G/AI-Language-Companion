import '../entities/voice_session.dart';

abstract class VoiceRepository {
  Future<VoiceSession> startSession({
    required String language,
    String? persona,
  });
  Future<VoiceSession> endSession(String sessionId);
  Future<PronunciationScore> evaluateSpeaking(
    String transcriptText, {
    String? targetLanguage,
  });
  Future<List<VoiceSession>> getSessions({int limit = 20});
}
