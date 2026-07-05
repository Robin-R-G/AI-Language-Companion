// lib/features/voice/data/datasources/voice_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      sessionId: json['session_id'] ?? '',
      token: json['token'] ?? '',
      roomId: json['room_id'] ?? '',
      livekitUrl: json['livekit_url'] ?? '',
    );
  }
}

abstract class VoiceRemoteDataSource {
  Future<Result<VoiceSessionResult>> startSession({
    required String language,
    String? persona,
  });

  Future<Result<VoiceSession>> endSession(String sessionId);
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
      final response = await _dio.post(
        '/voice/session',
        data: {
          'language': language,
          if (persona != null) 'persona': persona,
        },
      );

      if (response.data['success'] == true) {
        return Result.success(VoiceSessionResult.fromJson(response.data['data']));
      }

      return Result.error(NetworkFailure(response.data['message'] ?? 'Session start failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Session start failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Session start failed: $e'));
    }
  }

  @override
  Future<Result<VoiceSession>> endSession(String sessionId) async {
    try {
      final response = await _dio.post(
        '/voice/end',
        data: {'session_id': sessionId},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return Result.success(VoiceSession(
          id: sessionId,
          userId: _client.auth.currentUser?.id ?? '',
          provider: 'livekit',
          duration: data['duration_seconds'] ?? 0,
          roomId: data['room_id'] ?? '',
        ));
      }

      return Result.error(NetworkFailure(response.data['message'] ?? 'Session end failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Session end failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Session end failed: $e'));
    }
  }
}
