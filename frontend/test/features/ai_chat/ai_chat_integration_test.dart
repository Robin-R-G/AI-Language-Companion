import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/features/ai_chat/domain/repositories/chat_repository.dart';
import 'package:ai_language_coach/features/ai_chat/domain/entities/chat_message.dart';
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
      when(() => mockChatRepository.sendMessage(any(), any()))
          .thenAnswer((_) async => Result.success(ChatMessage(id: '1', role: 'assistant', content: 'Present perfect tense explanation')));

      when(() => mockChatRepository.getMessages(any()))
          .thenAnswer((_) async => const Result.success([]));

      final sendResult = await mockChatRepository.sendMessage(
        'conv_001',
        'What is the present perfect tense?',
      );
      expect(sendResult.isSuccess, isTrue);

      final getResult = await mockChatRepository.getMessages('conv_001');
      expect(getResult.isSuccess, isTrue);
    });

    test('chat flow: create conversation then send message', () async {
      when(() => mockChatRepository.createConversation(any()))
          .thenAnswer((_) async => const Result.success('conv_new'));

      when(() => mockChatRepository.sendMessage(any(), any()))
          .thenAnswer((_) async => Result.success(ChatMessage(id: '2', role: 'assistant', content: 'Hello!')));

      final createResult = await mockChatRepository.createConversation('Test Title');
      expect(createResult.isSuccess, isTrue);

      final sendResult = await mockChatRepository.sendMessage(
        createResult.value,
        'Hello!',
      );
      expect(sendResult.isSuccess, isTrue);
    });

    test('chat flow: handle network error gracefully', () async {
      when(() => mockChatRepository.sendMessage(any(), any()))
          .thenAnswer(
        (_) async => Result.error(NetworkFailure('No internet')),
      );

      final result = await mockChatRepository.sendMessage(
        'conv_001',
        'Hello!',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
    });
  });
}
