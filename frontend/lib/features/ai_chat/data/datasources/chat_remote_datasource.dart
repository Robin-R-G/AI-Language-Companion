// lib/features/ai_chat/data/datasources/chat_remote_datasource.dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
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
    String? language,
    String? examType,
    void Function(String chunk)? onChunk,
  });

  Future<Result<List<ChatMessage>>> getMessages(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _client;

  ChatRemoteDataSourceImpl({Dio? dio, SupabaseClient? client})
      : _dio = dio ?? Dio(),
        _client = client ?? Supabase.instance.client;

  String get _functionsBaseUrl =>
      '${AppConstants.supabaseUrl}${AppConstants.apiBaseUrl}';

  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'apikey': AppConstants.supabaseAnonKey,
        if (_client.auth.currentSession?.accessToken != null)
          'Authorization':
              'Bearer ${_client.auth.currentSession!.accessToken}',
      };

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
    String? language,
    String? examType,
    void Function(String chunk)? onChunk,
  }) async {
    try {
      // Store user message in Supabase
      await _client.from('chat_messages').insert({
        'conversation_id': conversationId,
        'role': 'user',
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final body = <String, dynamic>{
        'message': message,
        'conversation_id': conversationId,
        if (language != null) 'language': language,
        if (examType != null) 'exam_type': examType,
      };

      if (stream) {
        return _sendMessageStreaming(body, conversationId, onChunk: onChunk);
      } else {
        return _sendMessageNonStreaming(body, conversationId);
      }
    } catch (e) {
      return Result.error(NetworkFailure('Send failed: $e'));
    }
  }

  Future<Result<ChatMessage>> _sendMessageNonStreaming(
    Map<String, dynamic> body,
    String conversationId,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'ai-chat',
        body: body,
      );

      if (response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final reply = (data['reply'] as String?) ?? '';
        final tokensUsed = (data['tokens_used'] as int?) ?? 0;
        final grammarFeedback =
            data['grammar_feedback'] as Map<String, dynamic>?;
        final translation = data['translation'] as String?;

        // Store AI response in Supabase
        final aiMessage = await _client
            .from('chat_messages')
            .insert({
              'conversation_id': conversationId,
              'role': 'assistant',
              'content': reply,
              'token_count': tokensUsed,
              'grammar_feedback': grammarFeedback,
              'translation': translation,
              'timestamp': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        return Result.success(ChatMessage.fromJson(aiMessage));
      }

      return const Result.error(NetworkFailure('Empty response from AI'));
    } catch (e) {
      return Result.error(NetworkFailure('Send failed: $e'));
    }
  }

  Future<Result<ChatMessage>> _sendMessageStreaming(
    Map<String, dynamic> body,
    String conversationId, {
    void Function(String chunk)? onChunk,
  }) async {
    try {
      final response = await _dio.post(
        '$_functionsBaseUrl/ai-chat',
        data: body,
        options: Options(
          responseType: ResponseType.stream,
          headers: _authHeaders,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final responseBody = response.data as ResponseBody;
      final stream = responseBody.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        final lines = text.split('\n');

        for (final line in lines) {
          if (line.startsWith('data:')) {
            final data = line.substring(5).trim();

            if (data == '[DONE]') break;

            try {
              final jsonData = jsonDecode(data);
              if (jsonData is Map<String, dynamic>) {
                final textChunk = jsonData['text'] as String? ??
                    jsonData['content'] as String? ??
                    '';
                if (textChunk.isNotEmpty) {
                  buffer.write(textChunk);
                  onChunk?.call(textChunk);
                }
              } else if (jsonData is String && jsonData.isNotEmpty) {
                buffer.write(jsonData);
                onChunk?.call(jsonData);
              }
            } catch (_) {
              // Not JSON — treat as plain text chunk
              if (data.isNotEmpty) {
                buffer.write(data);
                onChunk?.call(data);
              }
            }
          }
        }
      }

      final fullReply = buffer.toString();

      if (fullReply.isEmpty) {
        return const Result.error(NetworkFailure('Empty response from AI'));
      }

      // Store AI response in Supabase
      final aiMessage = await _client
          .from('chat_messages')
          .insert({
            'conversation_id': conversationId,
            'role': 'assistant',
            'content': fullReply,
            'timestamp': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Result.success(ChatMessage.fromJson(aiMessage));
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
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(messages);
    } catch (e) {
      return Result.error(NetworkFailure('Failed to load messages: $e'));
    }
  }
}
