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

  Future<void> sendMessage(String message, {String? language, String? examType}) async {
    if (_conversationId == null) {
      await startConversation();
    }

    final currentMessages = state.value ?? [];
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _conversationId!,
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );
    state = AsyncValue.data([...currentMessages, userMsg]);

    // Placeholder for streaming AI response
    final aiMsgId = '${DateTime.now().millisecondsSinceEpoch}_ai';
    final aiPlaceholder = ChatMessage(
      id: aiMsgId,
      conversationId: _conversationId!,
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
    );
    state = AsyncValue.data([...state.value ?? [], aiPlaceholder]);

    final repository = ref.read(chatRepositoryProvider);
    final result = await repository.sendMessage(
      conversationId: _conversationId!,
      message: message,
      stream: true,
      language: language,
      examType: examType,
      onChunk: (chunk) {
        final current = state.value ?? [];
        final idx = current.indexWhere((m) => m.id == aiMsgId);
        if (idx != -1) {
          final updated = [...current];
          updated[idx] = updated[idx].copyWith(
            content: updated[idx].content + chunk,
          );
          state = AsyncValue.data(updated);
        }
      },
    );

    result.fold(
      (failure) {
        // Remove placeholder on error
        final current = state.value ?? [];
        state = AsyncValue.data(
          current.where((m) => m.id != aiMsgId).toList(),
        );
      },
      (reply) {
        // Replace placeholder with final message
        final current = state.value ?? [];
        final idx = current.indexWhere((m) => m.id == aiMsgId);
        if (idx != -1) {
          final updated = [...current];
          updated[idx] = reply;
          state = AsyncValue.data(updated);
        }
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
