// lib/features/ai_chat/presentation/controllers/chat_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../../shared/models/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_controller.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl();
}

@riverpod
class ChatController extends _$ChatController {
  String? _conversationId;

  @override
  AsyncValue<List<ChatMessage>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> startConversation({String? title}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(chatRepositoryProvider);
    final result = await repository.createConversation(
      title: title ?? 'New conversation',
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (conversation) {
        _conversationId = conversation.id;
        state = const AsyncValue.data([]);
      },
    );
  }

  Future<void> sendMessage(String message) async {
    if (_conversationId == null) {
      await startConversation();
    }

    final currentMessages = state.value ?? [];
    state = AsyncValue.data([
      ...currentMessages,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: _conversationId!,
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      ),
    ]);

    final repository = ref.read(chatRepositoryProvider);
    final result = await repository.sendMessage(
      conversationId: _conversationId!,
      message: message,
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (reply) {
        final messages = state.value ?? [];
        state = AsyncValue.data([...messages, reply]);
      },
    );
  }

  Future<void> loadMessages() async {
    if (_conversationId == null) return;

    state = const AsyncValue.loading();
    final repository = ref.read(chatRepositoryProvider);
    final result = await repository.getMessages(_conversationId!);

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (messages) => state = AsyncValue.data(messages),
    );
  }

  void clearConversation() {
    _conversationId = null;
    state = const AsyncValue.data([]);
  }
}
