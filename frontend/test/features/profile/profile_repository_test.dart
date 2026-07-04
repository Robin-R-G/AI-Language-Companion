import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/profile/data/repositories/profile_repository_impl.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = ProfileRepositoryImpl(dio: mockDio);
  });

  group('ProfileRepositoryImpl', () {
    test('updateProfile succeeds', () async {
      when(
        () => mockDio.put(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => MockResponse());

      final result = await repository.updateProfile({
        'display_name': 'New Name',
      });
      expect(result.isSuccess, true);
      verify(
        () => mockDio.put(
          any(),
          data: any(
            named: 'data',
            that: containsPair('display_name', 'New Name'),
          ),
        ),
      ).called(1);
    });

    test('uploadAvatar returns url on success', () async {
      final response = MockResponse();
      when(
        () => response.data,
      ).thenReturn({'url': 'https://example.com/avatar.png'});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.uploadAvatar('/path/to/file.png');
      expect(result.isSuccess, true);
      expect(result.value, 'https://example.com/avatar.png');
    });

    test('uploadAvatar handles invalid format', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({});
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.uploadAvatar('file.png');
      expect(result.isFailure, true);
    });

    test('deleteAccount succeeds', () async {
      when(() => mockDio.delete(any())).thenAnswer((_) async => MockResponse());

      final result = await repository.deleteAccount();
      expect(result.isSuccess, true);
    });

    test('handles DioException on updateProfile', () async {
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Database error',
        ),
      );

      final result = await repository.updateProfile({});
      expect(result.isFailure, true);
    });

    test('handles DioException on uploadAvatar', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Upload failed',
        ),
      );

      final result = await repository.uploadAvatar('file.png');
      expect(result.isFailure, true);
    });
  });
}
