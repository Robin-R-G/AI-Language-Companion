import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_language_coach/features/auth/data/repositories/auth_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockSupabaseClient mockSupabase;
  late MockSupabaseAuth mockAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockSupabaseAuth();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    repository = AuthRepositoryImpl(client: mockSupabase);
  });

  group('AuthRepositoryImpl', () {
    test('signUp returns AuthUser on success', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user_1');
      when(() => mockUser.email).thenReturn('test@test.com');
      when(() => mockUser.userMetadata).thenReturn(null);
      when(() => mockUser.createdAt).thenReturn('2024-01-01T00:00:00.000');

      final response = MockAuthResponse();
      when(() => response.user).thenReturn(mockUser);
      when(
        () => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password'), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.signUp(email: 'test@test.com', password: 'password123', name: 'Test');
      expect(result.isSuccess, true);
      expect(result.value.email, 'test@test.com');
    });

    test('signUp returns error when user is null', () async {
      final response = MockAuthResponse();
      when(() => response.user).thenReturn(null);
      when(
        () => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password'), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.signUp(email: 'test@test.com', password: 'password123', name: 'Test');
      expect(result.isFailure, true);
    });

    test('signUp catches exceptions', () async {
      when(
        () => mockAuth.signUp(email: any(named: 'email'), password: any(named: 'password'), data: any(named: 'data')),
      ).thenThrow(Exception('Network error'));

      final result = await repository.signUp(email: 'test@test.com', password: 'password123', name: 'Test');
      expect(result.isFailure, true);
    });

    test('signIn returns AuthUser on success', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user_1');
      when(() => mockUser.email).thenReturn('test@test.com');
      when(() => mockUser.userMetadata).thenReturn(null);
      when(() => mockUser.createdAt).thenReturn('2024-01-01T00:00:00.000');

      final response = MockAuthResponse();
      when(() => response.user).thenReturn(mockUser);
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.signIn(email: 'test@test.com', password: 'password123');
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
  });
}
