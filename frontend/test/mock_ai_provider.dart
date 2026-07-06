import 'package:ai_language_coach/features/ai_chat/domain/entities/chat_message.dart';
import 'package:ai_language_coach/core/errors/failure.dart';

/// Mock AI provider for testing purposes
class MockAIProvider {
  final List<ChatMessage> _responses;

  MockAIProvider({List<ChatMessage>? responses}) : _responses = responses ?? [];

  /// Returns a canned chat response
  ChatMessage getChatResponse(String userMessage) {
    if (_responses.isNotEmpty) {
      return _responses.removeAt(0);
    }

    return ChatMessage(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: 'mock_conv',
      role: 'assistant',
      content: 'This is a mock AI response to: "$userMessage"',
      timestamp: DateTime.now(),
    );
  }

  /// Returns a canned grammar feedback
  GrammarFeedback getGrammarFeedback(String text) {
    return GrammarFeedback(
      isCorrect: text.toLowerCase() == text,
      original: text,
      corrected: text,
      explanation: 'Mock grammar explanation',
      explanationMalayalam: 'Mock Malayalam explanation',
      category: 'Mock Category',
      examples: ['Example 1', 'Example 2'],
    );
  }

  /// Returns a canned translation
  TranslationData getTranslation(String text) {
    return TranslationData(
      translation: 'Translated: $text',
      pronunciation: '/mock pronunciation/',
      alternativeExpressions: {'casual': 'Casual', 'formal': 'Formal'},
      explanation: 'Mock translation explanation',
    );
  }

  /// Returns a mock failure
  AIServiceFailure getFailure() {
    return const AIServiceFailure('Mock AI service error');
  }
}

/// Creates test chat messages
ChatMessage createTestUserMessage({String? content}) {
  return ChatMessage(
    id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
    conversationId: 'test_conv',
    role: 'user',
    content: content ?? 'Test user message',
    timestamp: DateTime.now(),
  );
}

ChatMessage createTestAssistantMessage({String? content}) {
  return ChatMessage(
    id: 'test_assistant_${DateTime.now().millisecondsSinceEpoch}',
    conversationId: 'test_conv',
    role: 'assistant',
    content: content ?? 'Test assistant response',
    timestamp: DateTime.now(),
  );
}
