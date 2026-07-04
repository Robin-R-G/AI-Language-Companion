import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;

  ChatRepositoryImpl({DioClient? dioClient})
      : _dio = dioClient?.client ?? DioClient().client;

  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/ai-chat',
        queryParameters: {
          'conversation_id': conversationId,
          'limit': limit,
          'offset': offset,
        },
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw ServerFailure(
        e.message ?? 'Failed to fetch messages',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<ChatMessage> sendMessage(
    String conversationId,
    String message, {
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
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatMessage.fromJson(data);
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw AIServiceFailure(
        e.message ?? 'Failed to send message',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw AIServiceFailure(e.message);
    }
  }

  @override
  Future<String> createConversation(String title) async {
    try {
      final response = await _dio.post(
        '/ai-chat',
        data: {
          'action': 'create_conversation',
          'title': title,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['id'] is String) {
        return data['id'] as String;
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw ServerFailure(
        e.message ?? 'Failed to create conversation',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getConversations({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/ai-chat',
        queryParameters: {
          'action': 'list_conversations',
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      throw const FormatException('Invalid response format');
    } on DioException catch (e) {
      throw ServerFailure(
        e.message ?? 'Failed to fetch conversations',
        code: e.response?.statusCode?.toString(),
      );
    } on FormatException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
