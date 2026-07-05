// lib/features/ai_chat/domain/services/conversation_engine.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ai_router_service.dart';

part 'conversation_engine.g.dart';

class ConversationMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });
}

class ConversationSession {
  final String id;
  final String userId;
  final String mode; // 'conversation', 'tutoring', 'exam_prep'
  final List<ConversationMessage> messages;
  final DateTime startedAt;
  final Map<String, dynamic>? context;

  ConversationSession({
    required this.id,
    required this.userId,
    required this.mode,
    required this.messages,
    required this.startedAt,
    this.context,
  });

  int get messageCount => messages.length;

  Duration get duration => DateTime.now().difference(startedAt);
}

@riverpod
class ConversationEngine extends _$ConversationEngine {
  ConversationSession? _currentSession;
  final AIRouterService _aiRouter;

  ConversationEngine(this._aiRouter);

  @override
  ConversationSession? build() {
    return null;
  }

  Future<void> startSession({
    required String userId,
    String mode = 'conversation',
    Map<String, dynamic>? context,
  }) async {
    final session = ConversationSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      mode: mode,
      messages: [],
      startedAt: DateTime.now(),
      context: context,
    );

    _currentSession = session;
    state = session;

    // Load conversation history from Supabase
    await _loadConversationHistory(userId);
  }

  Future<void> _loadConversationHistory(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      if (response != null && response.isNotEmpty) {
        final messages = (response as List).map((msg) {
          return ConversationMessage(
            id: msg['id'],
            role: msg['role'],
            content: msg['content'],
            timestamp: DateTime.parse(msg['created_at']),
            metadata: msg['metadata'],
          );
        }).toList();

        _currentSession = ConversationSession(
          id: _currentSession!.id,
          userId: userId,
          mode: _currentSession!.mode,
          messages: messages.reversed.toList(),
          startedAt: _currentSession!.startedAt,
          context: _currentSession!.context,
        );

        state = _currentSession;
      }
    } catch (e) {
      print('Error loading conversation history: $e');
    }
  }

  Future<String> sendMessage(String content, {String? conversationId}) async {
    if (_currentSession == null) {
      throw Exception('No active session. Call startSession() first.');
    }

    // Add user message
    final userMessage = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
      timestamp: DateTime.now(),
    );

    _currentSession!.messages.add(userMessage);
    state = _currentSession;

    // Save to Supabase
    await _saveMessage(userMessage, conversationId);

    // Get AI response
    final response = await _aiRouter.chat(
      userId: _currentSession!.userId,
      message: content,
      conversationId: conversationId ?? _currentSession!.id,
      context: _currentSession!.context,
    );

    final assistantMessage = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'assistant',
      content: response['message'] ?? response['content'] ?? 'I understand.',
      timestamp: DateTime.now(),
      metadata: response['metadata'],
    );

    _currentSession!.messages.add(assistantMessage);
    state = _currentSession;

    // Save AI response
    await _saveMessage(assistantMessage, conversationId);

    return assistantMessage.content;
  }

  Future<void> _saveMessage(ConversationMessage message, String? conversationId) async {
    try {
      await Supabase.instance.client.from('chat_messages').insert({
        'user_id': _currentSession!.userId,
        'conversation_id': conversationId ?? _currentSession!.id,
        'role': message.role,
        'content': message.content,
        'metadata': message.metadata,
      });
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  void endSession() {
    _currentSession = null;
    state = null;
  }

  List<ConversationMessage> getMessages({int? limit}) {
    if (_currentSession == null) return [];
    final messages = _currentSession!.messages;
    if (limit != null && messages.length > limit) {
      return messages.sublist(messages.length - limit);
    }
    return messages;
  }

  Map<String, dynamic> getSessionStats() {
    if (_currentSession == null) {
      return {'message_count': 0, 'duration_minutes': 0};
    }

    return {
      'message_count': _currentSession!.messageCount,
      'duration_minutes': _currentSession!.duration.inMinutes,
      'mode': _currentSession!.mode,
    };
  }
}
