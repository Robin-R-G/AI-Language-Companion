import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ai_language_coach/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ai_language_coach/features/auth/domain/entities/user.dart';
import '..\..\mocks/mocks.dart';

class MockAuthResponse extends Mock implements AuthResponse {}
class MockSupabaseSession extends Mock implements Session {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockSupabaseAuth mockAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockSupabaseAuth();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    repository = AuthRepositoryImpl(mockSupabase);
  });

  group('AuthRepositoryImpl', () {
    test('signUp returns AppUser on success', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user_1');
      when(() => mockUser.email).thenReturn('test@test.com');
      when(() => mockUser.userMetadata).thenReturn(null);
      when(() => mockUser.createdAt).thenReturn('2026-07-04T00:00:00.000');

      final response = MockAuthResponse();
      when(() => response.user).thenReturn(mockUser);
      when(
        () => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => response);

      final result = await repository.signUp('test@test.com', 'password123');
      expect(result.isSuccess, true);
      expect(result.value.email, 'test@test.com');
    });

    test('signUp returns error when user is null', () async {
      final response = MockAuthResponse();
      when(() => response.user).thenReturn(null);
      when(
        () => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => response);

      final result = await repository.signUp('test@test.com', 'password123');
      expect(result.isFailure, true);
    });

    test('signUp catches exceptions', () async {
      when(
        () => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password')),
      ).thenThrow(Exception('Network error'));

      final result = await repository.signUp('test@test.com', 'password123');
      expect(result.isFailure, true);
    });

    test('signIn returns AppUser on success', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user_1');
      when(() => mockUser.email).thenReturn('test@test.com');
      when(() => mockUser.userMetadata).thenReturn(null);
      when(() => mockUser.createdAt).thenReturn('2026-07-04T00:00:00.000');

      final response = MockAuthResponse();
      when(() => response.user).thenReturn(mockUser);
      when(
        () => mockAuth.signInWithPassword(email: any(named: 'email'), password: any(named: 'password')),
      ).thenAnswer((_) async => response);

      final result = await repository.signIn('test@test.com', 'password123');
      expect(result.isSuccess, true);
      expect(result.value.id, 'user_1');
    });

    test('signOut succeeds', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();
      expect(result.isSuccess, true);
    });

    test('signOut catches exceptions', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('err'));
      final result = await repository.signOut();
      expect(result.isFailure, true);
    });

    test('currentUser returns null when no user', () {
      when(() => mockSupabase.auth.currentUser).thenReturn(null);
      expect(repository.currentUser, isNull);
    });

    test('authStateChanges maps to bool', () {
      when(() => mockSupabase.auth.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      expect(repository.authStateChanges, isA<Stream<bool>>());
    });
  });
}
