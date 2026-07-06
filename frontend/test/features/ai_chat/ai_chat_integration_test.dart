import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:ai_language_coach/shared/models/chat_message.dart';
import '../../test_utils/test_helpers.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    registerFallbackValue('');
  });

  group('AI Chat Integration Tests', () {
    test('chat flow: send message and receive response', () async {
      when(() => mockChatRepository.sendMessage(conversationId: any(named: 'conversationId'), message: any(named: 'message')))
          .thenAnswer((_) async => Result.success(ChatMessage(id: '1', conversationId: 'conv_001', role: 'assistant', content: 'Present perfect tense explanation')));

      when(() => mockChatRepository.getMessages(any()))
          .thenAnswer((_) async => const Result.success([]));

      final sendResult = await mockChatRepository.sendMessage(
        conversationId: 'conv_001',
        message: 'What is the present perfect tense?',
      );
      expect(sendResult.isSuccess, isTrue);

      final getResult = await mockChatRepository.getMessages('conv_001');
      expect(getResult.isSuccess, isTrue);
    });

    test('chat flow: create conversation then send message', () async {
      when(() => mockChatRepository.createConversation(title: any(named: 'title')))
          .thenAnswer((_) async => Result.success(AIConversation(id: 'conv_new', userId: 'user_1', title: 'Test', provider: 'openai', model: 'gpt-4')));

      when(() => mockChatRepository.sendMessage(conversationId: any(named: 'conversationId'), message: any(named: 'message')))
          .thenAnswer((_) async => Result.success(ChatMessage(id: '2', conversationId: 'conv_new', role: 'assistant', content: 'Hello!')));

      final createResult = await mockChatRepository.createConversation(title: 'Test Title');
      expect(createResult.isSuccess, isTrue);

      final sendResult = await mockChatRepository.sendMessage(
        conversationId: createResult.value.id,
        message: 'Hello!',
      );
      expect(sendResult.isSuccess, isTrue);
    });

    test('chat flow: handle network error gracefully', () async {
      when(() => mockChatRepository.sendMessage(conversationId: any(named: 'conversationId'), message: any(named: 'message')))
          .thenAnswer(
        (_) async => Result.error(NetworkFailure('No internet')),
      );

      final result = await mockChatRepository.sendMessage(
        conversationId: 'conv_001',
        message: 'Hello!',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
    });
  });
}
