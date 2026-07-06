// lib/features/notifications/presentation/controllers/notifications_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/gamification.dart';

part 'notifications_controller.g.dart';

@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  AsyncValue<List<Notification>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      state = const AsyncValue.error('Not authenticated', StackTrace.empty);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('sent_at', ascending: false)
          .limit(50);

      final notifications = (response as List)
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(notifications);
    } catch (e) {
      state = AsyncValue.error('Failed to load notifications: $e', StackTrace.current);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId);

      await loadNotifications();
    } catch (e) {
      state = AsyncValue.error('Failed to mark as read: $e', StackTrace.current);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      await loadNotifications();
    } catch (e) {
      state = AsyncValue.error('Failed to delete: $e', StackTrace.current);
    }
  }

  int get unreadCount {
    return state.value?.where((n) => n.readAt == null).length ?? 0;
  }
}
