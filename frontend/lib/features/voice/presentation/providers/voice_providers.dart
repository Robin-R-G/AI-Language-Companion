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
class VoiceSessionState extends _$VoiceSessionState {
  @override
  AsyncValue<VoiceSession?> build() => const AsyncValue.data(null);

  Future<void> startSession(String language) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(voiceRepositoryProvider);
      final session = await repo.startSession(language: language);
      state = AsyncValue.data(session);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> endSession() async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(voiceRepositoryProvider);
      final ended = await repo.endSession(currentSession.id);
      state = AsyncValue.data(ended);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class PronunciationState extends _$PronunciationState {
  @override
  AsyncValue<PronunciationScore?> build() => const AsyncValue.data(null);

  Future<void> evaluate(String transcript, {String? targetLanguage}) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(voiceRepositoryProvider);
      final score =
          await repo.evaluateSpeaking(transcript, targetLanguage: targetLanguage);
      state = AsyncValue.data(score);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class VoiceSessionsHistory extends _$VoiceSessionsHistory {
  @override
  AsyncValue<List<VoiceSession>> build() => const AsyncValue.data([]);

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(voiceRepositoryProvider);
      final sessions = await repo.getSessions();
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
