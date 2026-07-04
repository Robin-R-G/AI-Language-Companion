import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  });
  Future<ChatMessage> sendMessage(
    String conversationId,
    String message, {
    bool stream = false,
  });
  Future<String> createConversation(String title);
  Future<List<Map<String, dynamic>>> getConversations({int limit = 20});
}
