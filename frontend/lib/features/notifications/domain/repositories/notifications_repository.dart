import '../../../../core/errors/result.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications({int limit = 50});
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
  Future<Result<void>> deleteNotification(String id);
}
