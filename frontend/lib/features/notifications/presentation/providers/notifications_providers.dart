import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/app_notification.dart';

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  final result = await repo.getNotifications();
  if (result.isSuccess) return result.value;
  throw result.failure;
});
