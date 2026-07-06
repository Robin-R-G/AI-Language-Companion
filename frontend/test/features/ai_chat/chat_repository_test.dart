import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_language_coach/features/ai_chat/data/repositories/chat_repository_impl.dart';
import 'package:ai_language_coach/features/ai_chat/data/datasources/chat_remote_datasource.dart';
import 'package:ai_language_coach/shared/models/chat_message.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import '../../mocks/mocks.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late MockChatRemoteDataSource mockDataSource;
  late ChatRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockChatRemoteDataSource();
    repository = ChatRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('ChatRepositoryImpl', () {
    test('getMessages returns messages on success', () async {
      when(() => mockDataSource.getMessages(any()))
          .thenAnswer((_) async => const Result.success([]));

      final result = await repository.getMessages('conv_1');
      expect(result.isSuccess, true);
      expect(result.value.length, 0);
    });

    test('getMessages returns list on success', () async {
      when(() => mockDataSource.getMessages(any())).thenAnswer((_) async => Result.success([
        ChatMessage(id: '1', conversationId: 'conv_1', role: 'user', content: 'Hello'),
        ChatMessage(id: '2', conversationId: 'conv_1', role: 'assistant', content: 'Hi'),
      ]));

      final result = await repository.getMessages('conv_1');
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });

    test('sendMessage returns ChatMessage on success', () async {
      when(() => mockDataSource.sendMessage(
        conversationId: any(named: 'conversationId'),
        message: any(named: 'message'),
      )).thenAnswer((_) async => Result.success(
        ChatMessage(id: 'msg_1', conversationId: 'conv_1', role: 'assistant', content: 'Hello!'),
      ));

      final result = await repository.sendMessage(
        conversationId: 'conv_1',
        message: 'Hi',
      );
      expect(result.isSuccess, true);
      expect(result.value.content, 'Hello!');
    });

    test('createConversation returns AIConversation on success', () async {
      when(() => mockDataSource.createConversation(
        title: any(named: 'title'),
      )).thenAnswer((_) async => Result.success(
        AIConversation(id: 'conv_123', userId: 'user_1', title: 'New Chat', provider: 'openai', model: 'gpt-4'),
      ));

      final result = await repository.createConversation(title: 'New Chat');
      expect(result.isSuccess, true);
      expect(result.value.id, 'conv_123');
    });
  });
}
