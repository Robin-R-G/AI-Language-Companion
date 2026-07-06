import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../data/datasources/voice_remote_datasource.dart';
import '../../data/voice_platform_service.dart';

part 'voice_providers.g.dart';

@riverpod
class CurrentVoiceSession extends _$CurrentVoiceSession {
  @override
  VoiceSessionResult? build() => null;

  Future<void> startSession(String language, {String? persona}) async {
    state = null;
    final repo = ref.read(voiceRepositoryProvider);
    final result = await repo.startSession(language: language, persona: persona);
    result.fold((_) {}, (session) => state = session);
  }

  Future<void> endSession(String sessionId) async {
    final repo = ref.read(voiceRepositoryProvider);
    final result = await repo.endSession(sessionId);
    result.fold((_) {}, (_) => state = null);
  }
}

@riverpod
VoicePlatformService voicePlatformService(VoicePlatformServiceRef ref) {
  return VoicePlatformService();
}
