import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart' as domain;
import '../../domain/repositories/chat_repository.dart';

part 'chat_providers.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl();
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<domain.ChatMessage> build() => [];

  Future<void> loadMessages(String conversationId) async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.getMessages(conversationId);
    result.fold((_) {}, (messages) {
      state = messages
          .map((m) => domain.ChatMessage(
                id: m.id,
                conversationId: conversationId,
                role: m.role,
                content: m.content,
                timestamp: m.timestamp,
                tokenCount: m.tokenCount,
                latencyMs: m.latencyMs,
              ))
          .toList();
    });
  }

  Future<void> sendMessage(String conversationId, String message) async {
    final repo = ref.read(chatRepositoryProvider);
    final userMsg = domain.ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    final result = await repo.sendMessage(
      conversationId: conversationId,
      message: message,
    );
    result.fold((_) {}, (reply) {
      state = [
        ...state,
        domain.ChatMessage(
          id: reply.id,
          conversationId: conversationId,
          role: reply.role,
          content: reply.content,
          timestamp: reply.timestamp,
          tokenCount: reply.tokenCount,
          latencyMs: reply.latencyMs,
        ),
      ];
    });
  }

  Future<String?> createConversation(String title) async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.createConversation(title: title);
    return result.getOrNull()?.id;
  }
}

@riverpod
class ActiveConversationId extends _$ActiveConversationId {
  @override
  String build() => '';

  void set(String id) => state = id;
}
