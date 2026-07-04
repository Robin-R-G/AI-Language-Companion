import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;

  ChatRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<ChatMessage>>> getMessages(
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
        return Result.success(
          data
              .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch messages',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<ChatMessage>> sendMessage(
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
        return Result.success(ChatMessage.fromJson(data));
      }
      return const Result.error(AIServiceFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        AIServiceFailure(
          e.message ?? 'Failed to send message',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<String>> createConversation(String title) async {
    try {
      final response = await _dio.post(
        '/ai-chat',
        data: {'action': 'create_conversation', 'title': title},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['id'] is String) {
        return Result.success(data['id'] as String);
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to create conversation',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getConversations({
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/ai-chat',
        queryParameters: {'action': 'list_conversations', 'limit': limit},
      );
      final data = response.data;
      if (data is List) {
        return Result.success(data.cast<Map<String, dynamic>>());
      }
      return const Result.error(ServerFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        ServerFailure(
          e.message ?? 'Failed to fetch conversations',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
