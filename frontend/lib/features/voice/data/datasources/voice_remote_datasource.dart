// lib/features/voice/data/datasources/voice_remote_datasource.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../shared/models/exam.dart';

class VoiceSessionResult {
  final String sessionId;
  final String token;
  final String roomId;
  final String livekitUrl;

  const VoiceSessionResult({
    required this.sessionId,
    required this.token,
    required this.roomId,
    required this.livekitUrl,
  });

  factory VoiceSessionResult.fromJson(Map<String, dynamic> json) {
    return VoiceSessionResult(
      sessionId: (json['session_id'] as String?) ?? '',
      token: (json['token'] as String?) ?? '',
      roomId: (json['room_id'] as String?) ?? '',
      livekitUrl: (json['livekit_url'] as String?) ?? '',
    );
  }
}

abstract class VoiceRemoteDataSource {
  Future<Result<VoiceSessionResult>> startSession({
    required String language,
    String? persona,
  });

  Future<Result<VoiceSession>> endSession(String sessionId);

  Future<Result<Map<String, dynamic>>> generateToken({
    required String sessionId,
    required String roomName,
    required String identity,
  });

  Future<Result<Map<String, dynamic>>> transcribeAudio({
    required Uint8List audioData,
    String language = 'en',
  });

  Future<Result<Map<String, dynamic>>> analyzePronunciation({
    required String transcript,
    required String targetText,
    String language = 'en',
  });
}

class VoiceRemoteDataSourceImpl implements VoiceRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _client;

  VoiceRemoteDataSourceImpl({Dio? dio, SupabaseClient? client})
      : _dio = dio ?? Dio(),
        _client = client ?? Supabase.instance.client;

  @override
  Future<Result<VoiceSessionResult>> startSession({
    required String language,
    String? persona,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.error(AuthFailure('Not authenticated'));
      }

      final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
      final tokenResult = await generateToken(
        sessionId: userId,
        roomName: roomId,
        identity: userId,
      );

      return tokenResult.fold(
        (failure) => Result.error(failure),
        (tokenData) => Result.success(VoiceSessionResult(
          sessionId: userId,
          token: (tokenData['token'] as String?) ?? '',
          roomId: roomId,
          livekitUrl: (tokenData['livekit_url'] as String?) ?? '',
        )),
      );
    } catch (e) {
      return Result.error(NetworkFailure('Session start failed: $e'));
    }
  }

  @override
  Future<Result<VoiceSession>> endSession(String sessionId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.error(AuthFailure('Not authenticated'));
      }

      await _client.from('voice_sessions').update({
        'ended_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      }).eq('id', sessionId);

      return Result.success(VoiceSession(
        id: sessionId,
        userId: userId,
        provider: 'livekit',
        duration: 0,
        roomId: '',
      ));
    } catch (e) {
      return Result.error(NetworkFailure('Session end failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> generateToken({
    required String sessionId,
    required String roomName,
    required String identity,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'voice-service/token',
        body: {
          'sessionId': sessionId,
          'roomName': roomName,
          'identity': identity,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return Result.success((data['data'] as Map<String, dynamic>?) ?? {});
        }
        return Result.error(NetworkFailure(data['message'] as String? ?? 'Token generation failed'));
      }
      return Result.error(NetworkFailure('Token generation failed with status ${response.status}'));
    } catch (e) {
      return Result.error(NetworkFailure('Token generation failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> transcribeAudio({
    required Uint8List audioData,
    String language = 'en',
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': MultipartFile.fromBytes(audioData, filename: 'audio.webm'),
        'language': language,
      });

      // The configured Dio client already appends the active session token!
      final response = await _dio.post(
        '/voice-service/transcribe',
        data: formData,
      );

      if (response.data['success'] == true) {
        return Result.success((response.data['data'] as Map<String, dynamic>?) ?? {});
      }

      return Result.error(NetworkFailure((response.data['message'] as String?) ?? 'Transcription failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Transcription failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Transcription failed: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> analyzePronunciation({
    required String transcript,
    required String targetText,
    String language = 'en',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'voice-service/pronunciation',
        body: {
          'transcript': transcript,
          'target': targetText,
          'language': language,
        },
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return Result.success((data['data'] as Map<String, dynamic>?) ?? {});
        }
        return Result.error(NetworkFailure(data['message'] as String? ?? 'Pronunciation analysis failed'));
      }
      return Result.error(NetworkFailure('Pronunciation analysis failed with status ${response.status}'));
    } catch (e) {
      return Result.error(NetworkFailure('Pronunciation analysis failed: $e'));
    }
  }
}
