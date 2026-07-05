import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/ai_chat/data/repositories/chat_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late ChatRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = ChatRepositoryImpl(dio: mockDio);
  });

  group('ChatRepositoryImpl', () {
    test('getMessages returns messages on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {'id': '1', 'role': 'user', 'content': 'Hello'},
        {'id': '2', 'role': 'assistant', 'content': 'Hi'},
      ]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getMessages('conv_1');
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });

    test('getMessages handles invalid response format', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'invalid': 'object'});
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getMessages('conv_1');
      expect(result.isFailure, true);
    });

    test('getMessages handles DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        ),
      );

      final result = await repository.getMessages('conv_1');
      expect(result.isFailure, true);
      expect(result.failure.message, contains('Network error'));
    });

    test('sendMessage returns ChatMessage on success', () async {
      final response = MockResponse();
      when(
        () => response.data,
      ).thenReturn({'id': 'msg_1', 'role': 'assistant', 'content': 'Hello!'});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.sendMessage('conv_1', 'Hi');
      expect(result.isSuccess, true);
      expect(result.value.content, 'Hello!');
    });

    test('createConversation returns id on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'id': 'conv_123'});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.createConversation('New Chat');
      expect(result.isSuccess, true);
      expect(result.value, 'conv_123');
    });

    test('getConversations returns list on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        {'id': 'conv_1', 'title': 'Chat 1'},
        {'id': 'conv_2', 'title': 'Chat 2'},
      ]);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.getConversations();
      expect(result.isSuccess, true);
      expect(result.value.length, 2);
    });
  });
}
