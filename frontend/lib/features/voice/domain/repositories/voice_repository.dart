// lib/features/voice/domain/repositories/voice_repository.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/exam.dart';
import '../../data/datasources/voice_remote_datasource.dart';

abstract class VoiceRepository {
  Future<Result<VoiceSessionResult>> startSession({
    required String language,
    String? persona,
  });

  Future<Result<VoiceSession>> endSession(String sessionId);
}
