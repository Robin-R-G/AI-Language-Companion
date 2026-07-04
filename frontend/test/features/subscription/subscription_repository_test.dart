import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:ai_language_coach/features/subscription/data/repositories/subscription_repository_impl.dart';
import '..\..\mocks/mocks.dart';

void main() {
  late MockDio mockDio;
  late SubscriptionRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    repository = SubscriptionRepositoryImpl(dio: mockDio);
  });

  group('SubscriptionRepositoryImpl', () {
    test('getCurrentSubscription returns subscription on success', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn({
        'id': 'sub_1', 'user_id': 'u1', 'plan': 'premium', 'status': 'active',
      });
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getCurrentSubscription();
      expect(result.isSuccess, true);
      expect(result.value.plan, 'premium');
    });

    test('getCurrentSubscription handles invalid format', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn('not a map');
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getCurrentSubscription();
      expect(result.isFailure, true);
    });

    test('getPlans returns list on success', () async {
      final response = MockResponse<List<dynamic>>();
      when(() => response.data).thenReturn([
        {'id': 'p1', 'name': 'Monthly', 'description': 'Monthly plan', 'price': 9.99, 'currency': 'USD', 'period': 'monthly'},
      ]);
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await repository.getPlans();
      expect(result.isSuccess, true);
      expect(result.value.length, 1);
    });

    test('purchase returns subscription on success', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn({
        'id': 'sub_1', 'user_id': 'u1', 'plan': 'premium', 'status': 'active',
      });
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await repository.purchase('plan_1', 'com.coach.monthly');
      expect(result.isSuccess, true);
    });

    test('restorePurchases returns subscription on success', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn({
        'id': 'sub_1', 'user_id': 'u1', 'plan': 'premium', 'status': 'active',
      });
      when(() => mockDio.post(any())).thenAnswer((_) async => response);

      final result = await repository.restorePurchases();
      expect(result.isSuccess, true);
    });

    test('cancelSubscription succeeds', () async {
      when(() => mockDio.post(any())).thenAnswer((_) async => MockResponse<void>());

      final result = await repository.cancelSubscription();
      expect(result.isSuccess, true);
    });

    test('checkFeatureAccess returns bool on success', () async {
      final response = MockResponse<Map<String, dynamic>>();
      when(() => response.data).thenReturn({'has_access': true});
      when(
        () => mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      final result = await repository.checkFeatureAccess('unlimited_chat');
      expect(result.isSuccess, true);
      expect(result.value, true);
    });

    test('handles DioException', () async {
      when(() => mockDio.get(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Payment error',
      ));

      final result = await repository.getCurrentSubscription();
      expect(result.isFailure, true);
    });
  });
}
