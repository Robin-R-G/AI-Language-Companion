import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/voice_session.dart';
import '../../domain/repositories/voice_repository.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final Dio _dio;

  VoiceRepositoryImpl({DioClient? dioClient})
      : _dio = dioClient?.client ?? DioClient().client;

  @override
  Future<VoiceSession> startSession({
    required String language,
    String? persona,
  }) async {
    try {
      final response = await _dio.post(
        '/voice-session',
        data: {
          'language': language,
          if (persona != null) 'persona': persona,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return VoiceSession.fromJson(data);
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw VoiceServiceFailure(
        e.message ?? 'Failed to start voice session',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw VoiceServiceFailure(e.message);
    }
  }

  @override
  Future<VoiceSession> endSession(String sessionId) async {
    try {
      final response = await _dio.post(
        '/voice/end',
        data: {
          'session_id': sessionId,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return VoiceSession.fromJson(data);
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw VoiceServiceFailure(
        e.message ?? 'Failed to end voice session',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw VoiceServiceFailure(e.message);
    }
  }

  @override
  Future<PronunciationScore> evaluateSpeaking(
    String transcriptText, {
    String? targetLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/speaking-evaluate',
        data: {
          'transcript': transcriptText,
          if (targetLanguage != null) 'target_language': targetLanguage,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PronunciationScore.fromJson(data);
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw VoiceServiceFailure(
        e.message ?? 'Failed to evaluate speaking',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw VoiceServiceFailure(e.message);
    }
  }

  @override
  Future<List<VoiceSession>> getSessions({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/voice-session',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => VoiceSession.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw VoiceServiceFailure(
        e.message ?? 'Failed to fetch voice sessions',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw VoiceServiceFailure(e.message);
    }
  }
}
