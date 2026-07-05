// lib/features/ai_chat/data/datasources/chat_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../shared/models/chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<Result<AIConversation>> createConversation({
    required String title,
    String? provider,
    String? model,
  });

  Future<Result<ChatMessage>> sendMessage({
    required String conversationId,
    required String message,
    bool stream = false,
  });

  Future<Result<List<ChatMessage>>> getMessages(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _client;

  ChatRemoteDataSourceImpl({Dio? dio, SupabaseClient? client})
      : _dio = dio ?? Dio(),
        _client = client ?? Supabase.instance.client;

  @override
  Future<Result<AIConversation>> createConversation({
    required String title,
    String? provider,
    String? model,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Result.error(AuthFailure('Not authenticated'));
      }

      final response = await _client
          .from('ai_conversations')
          .insert({
            'user_id': userId,
            'title': title,
            'provider': provider ?? 'gemini',
            'model': model ?? 'gemini-1.5-flash',
          })
          .select()
          .single();

      return Result.success(AIConversation.fromJson(response));
    } catch (e) {
      return Result.error(DatabaseFailure('Failed to create conversation: $e'));
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String conversationId,
    required String message,
    bool stream = false,
  }) async {
    try {
      final response = await _dio.post(
        '/ai-chat',
        data: {
          'conversation_id': conversationId,
          'message': message,
          'stream': stream,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return Result.success(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          role: 'assistant',
          content: data['reply'] ?? '',
          tokenCount: data['tokens_used'] ?? 0,
          grammarFeedback: data['grammar_feedback'],
          translation: data['translation'],
        ));
      }

      return Result.error(NetworkFailure(response.data['message'] ?? 'Send failed'));
    } on DioException catch (e) {
      return Result.error(NetworkFailure('Send failed: ${e.message}'));
    } catch (e) {
      return Result.error(NetworkFailure('Send failed: $e'));
    }
  }

  @override
  Future<Result<List<ChatMessage>>> getMessages(String conversationId) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('timestamp', ascending: true)
          .limit(100);

      final messages = (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();

      return Result.success(messages);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load messages: $e'));
    }
  }
}
