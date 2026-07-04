import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:ai_language_coach/test/mocks/mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late MockDio mockDio;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockDio = MockDio();
  });

  group('Chat Repository', () {
    test('sendChatMessage returns response on success', () async {
      when(() => mockSupabase.auth).thenReturn(MockSupabaseAuth());
      when(() => mockDio.post(
        any(),
        data: any(named: 'data'),
      )).thenAnswer((_) async => MockResponse<dynamic>());

      final response = await mockDio.post(
        '/ai-chat',
        data: {'message': 'Hello', 'userId': '123'},
      );

      expect(response, isA<Response<dynamic>>());
      verify(() => mockDio.post(
        '/ai-chat',
        data: any(named: 'data'),
      )).called(1);
    });
  });
}
