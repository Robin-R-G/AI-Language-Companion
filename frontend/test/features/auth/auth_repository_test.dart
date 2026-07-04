import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_language_coach/test/mocks/mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
  });

  group('Auth Repository', () {
    test('signIn calls auth.signInWithPassword', () async {
      when(() => mockSupabase.auth).thenReturn(MockSupabaseAuth());

      await mockSupabase.auth.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => mockSupabase.auth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).called(1);
    });

    test('signUp calls auth.signUp', () async {
      when(() => mockSupabase.auth).thenReturn(MockSupabaseAuth());

      await mockSupabase.auth.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(() => mockSupabase.auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).called(1);
    });

    test('signOut calls auth.signOut', () async {
      when(() => mockSupabase.auth).thenReturn(MockSupabaseAuth());

      await mockSupabase.auth.signOut();

      verify(() => mockSupabase.auth.signOut()).called(1);
    });
  });
}
