import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/voice_repository_impl.dart';
import '../../domain/entities/voice_session.dart';
import '../../domain/repositories/voice_repository.dart';

part 'voice_providers.g.dart';

@riverpod
VoiceRepository voiceRepository(VoiceRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VoiceRepositoryImpl(dioClient: dioClient);
}

@riverpod
class CurrentVoiceSession extends _$CurrentVoiceSession {
  @override
  VoiceSession? build() => null;

  Future<void> startSession(String language) async {
    state = null;
    final repo = ref.read(voiceRepositoryProvider);
    final result = await repo.startSession(language: language);
    result.fold((_) {}, (session) => state = session);
  }

  Future<void> endSession() async {
    final currentSession = state;
    if (currentSession == null) return;
    final repo = ref.read(voiceRepositoryProvider);
    final result = await repo.endSession(currentSession.id);
    result.fold((_) {}, (ended) => state = ended);
  }
}

@riverpod
class PronunciationScoreState extends _$PronunciationScoreState {
  @override
  PronunciationScore? build() => null;

  Future<void> evaluate(String transcript, {String? targetLanguage}) async {
    state = null;
    final repo = ref.read(voiceRepositoryProvider);
    final result = await repo.evaluateSpeaking(
      transcript,
      targetLanguage: targetLanguage,
    );
    result.fold((_) {}, (score) => state = score);
  }
}

@riverpod
class VoiceSessionsHistory extends _$VoiceSessionsHistory {
  @override
  List<VoiceSession> build() => [];

  Future<void> loadSessions() async {
    final repo = ref.read(voiceRepositoryProvider);
    final result = await repo.getSessions();
    result.fold((_) {}, (sessions) => state = sessions);
  }
}
