import '../../../../core/errors/result.dart';
import '../entities/voice_session.dart';

abstract class VoiceRepository {
  Future<Result<VoiceSession>> startSession({
    required String language,
    String? persona,
  });
  Future<Result<VoiceSession>> endSession(String sessionId);
  Future<Result<PronunciationScore>> evaluateSpeaking(
    String transcriptText, {
    String? targetLanguage,
  });
  Future<Result<List<VoiceSession>>> getSessions({int limit = 20});
}
