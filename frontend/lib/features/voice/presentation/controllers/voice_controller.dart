// lib/features/voice/presentation/controllers/voice_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/voice_remote_datasource.dart';
import '../../data/repositories/voice_repository_impl.dart';

part 'voice_controller.g.dart';

@riverpod
VoiceRepository voiceRepository(VoiceRepositoryRef ref) {
  return VoiceRepositoryImpl();
}

@riverpod
class VoiceController extends _$VoiceController {
  String? _sessionId;

  @override
  AsyncValue<VoiceSessionResult?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> startSession({
    required String language,
    String? persona,
  }) async {
    state = const AsyncValue.loading();
    final repository = ref.read(voiceRepositoryProvider);
    final result = await repository.startSession(
      language: language,
      persona: persona,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (session) {
        _sessionId = session.sessionId;
        state = AsyncValue.data(session);
      },
    );
  }

  Future<void> endSession() async {
    if (_sessionId == null) return;

    final repository = ref.read(voiceRepositoryProvider);
    await repository.endSession(_sessionId!);
    _sessionId = null;
    state = const AsyncValue.data(null);
  }
}
