// lib/features/ai_chat/domain/services/ai_router_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AIProvider { openai, gemini, claude }

enum AgentType {
  grammar,
  vocabulary,
  speaking,
  writing,
  reading,
  listening,
  pronunciation,
  translation,
  safetyReview,
  copyrightReview,
  qualityReview,
}

class AIRouterService {
  final Dio _dio;
  final String _baseUrl;
  AIProvider? _preferredProvider;

  AIRouterService(this._dio, {String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://your-project.supabase.co/functions/v1';

  void setPreferredProvider(AIProvider provider) {
    _preferredProvider = provider;
  }

  Future<Map<String, dynamic>> route({
    required AgentType agentType,
    required String userId,
    required Map<String, dynamic> input,
    AIProvider? provider,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/agent-orchestrate',
        data: {
          'agent_type': agentType.name,
          'input': input,
          'context': context ?? {},
          'preferred_provider': (provider ?? _preferredProvider)?.name,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return (responseData['data'] as Map<String, dynamic>?) ?? responseData;
      } else {
        throw Exception('AI routing failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> chat({
    required String userId,
    required String message,
    required String conversationId,
    Map<String, dynamic>? context,
    AIProvider? provider,
  }) async {
    return route(
      agentType: AgentType.vocabulary, // Default to vocabulary for chat
      userId: userId,
      input: {
        'message': message,
        'conversation_id': conversationId,
      },
      provider: provider,
      context: context,
    );
  }

  Future<Map<String, dynamic>> evaluateWriting({
    required String userId,
    required String text,
    required String topic,
    Map<String, dynamic>? context,
  }) async {
    return route(
      agentType: AgentType.writing,
      userId: userId,
      input: {
        'text': text,
        'topic': topic,
      },
      context: context,
    );
  }

  Future<Map<String, dynamic>> evaluateSpeaking({
    required String userId,
    required String audioBase64,
    String? expectedText,
    Map<String, dynamic>? context,
  }) async {
    return route(
      agentType: AgentType.speaking,
      userId: userId,
      input: {
        'audio': audioBase64,
        'expected_text': expectedText,
      },
      context: context,
    );
  }

  Future<Map<String, dynamic>> checkGrammar({
    required String userId,
    required String text,
    Map<String, dynamic>? context,
  }) async {
    return route(
      agentType: AgentType.grammar,
      userId: userId,
      input: {'text': text},
      context: context,
    );
  }

  Future<Map<String, dynamic>> generateLesson({
    required String userId,
    required String topic,
    required String skillType,
    Map<String, dynamic>? context,
  }) async {
    final agentType = AgentType.values.firstWhere(
      (e) => e.name == skillType,
      orElse: () => AgentType.vocabulary,
    );

    return route(
      agentType: agentType,
      userId: userId,
      input: {'topic': topic},
      context: context,
    );
  }

  Future<Map<String, dynamic>> translate({
    required String userId,
    required String text,
    required String targetLanguage,
    Map<String, dynamic>? context,
  }) async {
    return route(
      agentType: AgentType.translation,
      userId: userId,
      input: {
        'text': text,
        'target_language': targetLanguage,
      },
      context: context,
    );
  }
}

final aiRouterServiceProvider = Provider<AIRouterService>((ref) {
  final dio = Dio();
  return AIRouterService(dio);
});
