import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ai_language_coach/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ai_language_coach/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:ai_language_coach/core/errors/result.dart';
import 'package:ai_language_coach/core/errors/failure.dart';
import 'package:ai_language_coach/shared/models/user_profile.dart';
import '../../mocks/mocks.dart';

class MockProfileDataSource extends Mock implements ProfileRemoteDataSource {}

void main() {
  late MockProfileDataSource mockDataSource;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockProfileDataSource();
    repository = ProfileRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('ProfileRepositoryImpl', () {
    test('updateProfile succeeds', () async {
      when(() => mockDataSource.updateProfile(
        any(named: 'userId'),
        any(named: 'updates'),
      )).thenAnswer((_) async => Result.success(
        const UserProfile(
          id: 'up_1',
          authUserId: 'user_1',
          fullName: 'New Name',
          nativeLanguage: 'Malayalam',
          targetLanguage: 'en',
          proficiencyLevel: 'B1',
          targetExam: 'ielts',
        ),
      ));

      final result = await repository.updateProfile('user_1', {
        'display_name': 'New Name',
      });
      expect(result.isSuccess, true);
      verify(
        () => mockDataSource.updateProfile('user_1', {'display_name': 'New Name'}),
      ).called(1);
    });

    test('deleteAccount succeeds', () async {
      when(() => mockDataSource.deleteAccount(any()))
          .thenAnswer((_) async => const Result.success(null));

      final result = await repository.deleteAccount('user_1');
      expect(result.isSuccess, true);
    });

    test('handles error on updateProfile', () async {
      when(() => mockDataSource.updateProfile(
        any(named: 'userId'),
        any(named: 'updates'),
      )).thenAnswer((_) async => Result.error(DatabaseFailure('Database error')));

      final result = await repository.updateProfile('user_1', {});
      expect(result.isFailure, true);
    });
  });
}
