import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_language_coach/features/auth/domain/entities/user.dart';
import 'package:ai_language_coach/core/services/connectivity_service.dart';
import '../../test_utils/fake_services.dart';
import '../../test_utils/test_constants.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeConnectivityService fakeConnectivity;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeConnectivity = FakeConnectivityService();
  });

  tearDown(() {
    fakeAuthRepository.dispose();
    fakeConnectivity.dispose();
  });

  group('Authentication Flow', () {
    test('should sign up with valid credentials', () async {
      final result = await fakeAuthRepository.signUp(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.email, TestConstants.testUserEmail);
      expect(fakeAuthRepository.currentUser, isNotNull);
    });

    test('should sign in with valid credentials', () async {
      final result = await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.email, TestConstants.testUserEmail);
    });

    test('should sign out successfully', () async {
      await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );
      expect(fakeAuthRepository.currentUser, isNotNull);

      final result = await fakeAuthRepository.signOut();

      expect(result.isSuccess, isTrue);
      expect(fakeAuthRepository.currentUser, isNull);
    });

    test('should emit auth state changes', () async {
      final states = <bool>[];
      fakeAuthRepository.authStateChanges.listen(states.add);

      await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );
      await fakeAuthRepository.signOut();

      expect(states, [true, false]);
    });

    test('should fail sign in with wrong credentials', () async {
      fakeAuthRepository.setShouldFail(true);

      final result = await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        'wrong_password',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
    });

    test('should fail sign up when already exists', () async {
      fakeAuthRepository.setShouldFail(true);

      final result = await fakeAuthRepository.signUp(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      expect(result.isFailure, isTrue);
    });

    test('should handle offline state for auth', () {
      fakeConnectivity.setConnected(false);

      expect(fakeConnectivity.isConnected, isFalse);
    });

    test('should map user data correctly after sign in', () async {
      final result = await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      final user = result.value;
      expect(user.id, isNotEmpty);
      expect(user.email, TestConstants.testUserEmail);
    });
  });

  group('Auth State Management', () {
    test('should track authenticated state', () async {
      expect(fakeAuthRepository.currentUser, isNull);

      await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      expect(fakeAuthRepository.currentUser, isNotNull);
    });

    test('should clear user on sign out', () async {
      await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      await fakeAuthRepository.signOut();

      expect(fakeAuthRepository.currentUser, isNull);
    });

    test('should support multiple auth state listeners', () async {
      final states1 = <bool>[];
      final states2 = <bool>[];

      fakeAuthRepository.authStateChanges.listen(states1.add);
      fakeAuthRepository.authStateChanges.listen(states2.add);

      await fakeAuthRepository.signIn(
        TestConstants.testUserEmail,
        TestConstants.testUserPassword,
      );

      expect(states1, [true]);
      expect(states2, [true]);
    });
  });
}
