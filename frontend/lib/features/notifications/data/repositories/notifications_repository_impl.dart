import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final Dio _dio;

  NotificationsRepositoryImpl({DioClient? dioClient, Dio? dio})
    : _dio = dio ?? dioClient?.client ?? DioClient().client;

  @override
  Future<Result<List<AppNotification>>> getNotifications({int limit = 50}) async {
    try {
      final response = await _dio.get('/notifications', queryParameters: {'limit': limit});
      final data = response.data;
      if (data is List) {
        return Result.success(data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList());
      }
      return const Result.error(DatabaseFailure('Invalid response format'));
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to fetch notifications', code: e.response?.statusCode?.toString()));
    }
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    try {
      await _dio.put('/notifications/$id/read');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to mark as read', code: e.response?.statusCode?.toString()));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to mark all as read', code: e.response?.statusCode?.toString()));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _dio.delete('/notifications/$id');
      return const Result.success(null);
    } on DioException catch (e) {
      return Result.error(DatabaseFailure(e.message ?? 'Failed to delete notification', code: e.response?.statusCode?.toString()));
    }
  }
}
