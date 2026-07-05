import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/features/ai_chat/domain/entities/chat_message.dart';
import 'package:ai_language_coach/features/ai_chat/domain/repositories/chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
  });

  group('AI Chat Provider', () {
    test('should return messages from repository', () async {
      when(() => mockChatRepository.getMessages(any()))
          .thenAnswer((_) async => const Result.success([]));

      final result = await mockChatRepository.getMessages('conv_001');

      expect(result.isSuccess, isTrue);
      expect(result.value, isEmpty);
    });

    test('should handle empty conversation', () async {
      when(() => mockChatRepository.getMessages('empty_conv'))
          .thenAnswer((_) async => const Result.success([]));

      final result = await mockChatRepository.getMessages('empty_conv');

      expect(result.isSuccess, isTrue);
      expect(result.value, isEmpty);
    });

    test('should handle send message failure', () async {
      when(() => mockChatRepository.sendMessage(any(), any()))
          .thenAnswer(
        (_) async => Result.error(ServerFailure('Network error')),
      );

      final result = await mockChatRepository.sendMessage(
        'conv_001',
        'Hello',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
    });

    test('should send message successfully', () async {
      when(() => mockChatRepository.sendMessage(any(), any()))
          .thenAnswer(
        (_) async => Result.success(ChatMessage(id: '1', role: 'assistant', content: 'How do I use present perfect?')),
      );

      final result = await mockChatRepository.sendMessage(
        'conv_001',
        'How do I use present perfect?',
      );

      expect(result.isSuccess, isTrue);
    });

    test('should create conversation successfully', () async {
      when(() => mockChatRepository.createConversation(any()))
          .thenAnswer((_) async => const Result.success('conv_new'));

      final result = await mockChatRepository.createConversation('Test Title');

      expect(result.isSuccess, isTrue);
      expect(result.value, 'conv_new');
    });
  });
}
