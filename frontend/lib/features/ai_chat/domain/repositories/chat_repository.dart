import '../../../../core/errors/result.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Result<List<ChatMessage>>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  });
  Future<Result<ChatMessage>> sendMessage(
    String conversationId,
    String message, {
    bool stream = false,
  });
  Future<Result<String>> createConversation(String title);
  Future<Result<List<Map<String, dynamic>>>> getConversations({int limit = 20});
}
