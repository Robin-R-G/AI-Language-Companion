import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_providers.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRepositoryImpl(dioClient: dioClient);
}

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessage> build() => [];

  Future<void> loadMessages(String conversationId) async {
    final repo = ref.read(chatRepositoryProvider);
    final messages = await repo.getMessages(conversationId);
    state = messages;
  }

  Future<void> sendMessage(String conversationId, String message) async {
    final repo = ref.read(chatRepositoryProvider);
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    try {
      final reply = await repo.sendMessage(conversationId, message);
      state = [...state, reply];
    } catch (e) {
      // Keep user message, error handled by UI
    }
  }

  Future<void> createConversation(String title) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.createConversation(title);
  }
}

@riverpod
class ActiveConversationId extends _$ActiveConversationId {
  @override
  String build() => '';

  void set(String id) => state = id;
}

@riverpod
class ConversationsList extends _$ConversationsList {
  @override
  List<Map<String, dynamic>> build() => [];

  Future<void> loadConversations() async {
    final repo = ref.read(chatRepositoryProvider);
    state = await repo.getConversations();
  }
}
