// lib/features/voice/presentation/controllers/voice_controller.dart
import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/voice_remote_datasource.dart';
import '../../data/voice_platform_service.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../../../core/providers/repository_providers.dart';
import '../providers/voice_providers.dart';

part 'voice_controller.g.dart';

@riverpod
class VoiceController extends _$VoiceController {
  String? _sessionId;
  bool _isRecording = false;

  @override
  AsyncValue<VoiceSessionResult?> build() {
    return const AsyncValue.data(null);
  }

  bool get isRecording => _isRecording;

  Future<void> startSession(String conversationId, {String mode = 'conversation'}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(voiceRepositoryProvider);
    final platformService = ref.read(voicePlatformServiceProvider);

    final result = await repository.startSession(
      language: 'en',
      persona: mode,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (session) async {
        _sessionId = session.sessionId;
        state = AsyncValue.data(session);

        await platformService.connect(
          sessionId: session.sessionId,
          token: session.token,
          livekitUrl: session.livekitUrl,
        );

        _isRecording = true;
        await platformService.startRecording();
      },
    );
  }

  Future<void> stopSession() async {
    if (_sessionId == null) return;

    final platformService = ref.read(voicePlatformServiceProvider);
    _isRecording = false;

    await platformService.stopRecording();
    await platformService.disconnect();

    final repository = ref.read(voiceRepositoryProvider);
    await repository.endSession(_sessionId!);
    _sessionId = null;
    state = const AsyncValue.data(null);
  }

  Future<Map<String, dynamic>?> evaluatePronunciation(String conversationId) async {
    if (_sessionId == null) return null;

    final platformService = ref.read(voicePlatformServiceProvider);
    final sessionResult = state.value;

    if (sessionResult == null) return null;

    return {
      'session_id': sessionResult.sessionId,
      'room_id': sessionResult.roomId,
    };
  }

  Future<TranscriptionResult> transcribeAudio(Uint8List audioData, {String language = 'en'}) async {
    final platformService = ref.read(voicePlatformServiceProvider);
    return platformService.transcribeAudio(
      audioData: audioData,
      language: language,
    );
  }

  Future<PronunciationAnalysis> analyzePronunciation({
    required String transcript,
    required String targetText,
    String language = 'en',
  }) async {
    final platformService = ref.read(voicePlatformServiceProvider);
    return platformService.analyzePronunciation(
      transcript: transcript,
      targetText: targetText,
      language: language,
    );
  }

  Future<void> speakText(String text, {String language = 'en', String? voiceId}) async {
    final platformService = ref.read(voicePlatformServiceProvider);
    await platformService.speakText(
      text: text,
      language: language,
      voiceId: voiceId,
    );
  }
}
