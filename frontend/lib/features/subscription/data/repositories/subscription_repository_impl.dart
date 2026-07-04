import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<Subscription>> getCurrentSubscription() async {
    try {
      final response = await _dio.get('/subscription');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(Subscription.fromJson(data));
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch subscription',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<List<SubscriptionPlan>>> getPlans() async {
    try {
      final response = await _dio.get('/subscription/plans');
      final data = response.data;
      if (data is List) {
        return Result.success(
          data
              .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        DatabaseFailure(
          e.message ?? 'Failed to fetch plans',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Subscription>> purchase(
    String planId,
    String storeProductId,
  ) async {
    try {
      final response = await _dio.post(
        '/subscription/purchase',
        data: {'plan_id': planId, 'store_product_id': storeProductId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(Subscription.fromJson(data));
      }
      return const Result.error(PaymentFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        PaymentFailure(
          e.message ?? 'Failed to process purchase',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<Subscription>> restorePurchases() async {
    try {
      final response = await _dio.post('/subscription/restore');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return Result.success(Subscription.fromJson(data));
      }
      return const Result.error(PaymentFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        PaymentFailure(
          e.message ?? 'Failed to restore purchases',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> cancelSubscription() async {
    try {
      await _dio.post('/subscription/cancel');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(
        PaymentFailure(
          e.message ?? 'Failed to cancel subscription',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<bool>> checkFeatureAccess(String feature) async {
    try {
      final response = await _dio.get(
        '/subscription/feature',
        queryParameters: {'feature': feature},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['has_access'] is bool) {
        return Result.success(data['has_access'] as bool);
      }
      return const Result.error(PaymentFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(
        PaymentFailure(
          e.message ?? 'Failed to check feature access',
          code: e.response?.statusCode?.toString(),
        ),
      );
    }
  }
}
