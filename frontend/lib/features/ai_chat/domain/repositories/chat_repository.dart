// lib/features/ai_chat/domain/repositories/chat_repository.dart
import '../../../../core/errors/result.dart';
import '../../../../shared/models/chat_message.dart';

abstract class ChatRepository {
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
