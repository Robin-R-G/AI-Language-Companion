// lib/shared/models/gamification.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gamification.freezed.dart';
part 'gamification.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String userId,
    required String achievementName,
    required String badge,
    DateTime? unlockedAt,
    @Default(0) int xpReward,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String provider,
    required String plan,
    required String status,
    DateTime? renewalDate,
    DateTime? expiresAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String userId,
    required String transactionId,
    required double amount,
    required String currency,
    required String platform,
    required String status,
    DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String userId,
    required String title,
    required String body,
    required String type,
    DateTime? sentAt,
    DateTime? readAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@freezed
class AnalyticsEvent with _$AnalyticsEvent {
  const factory AnalyticsEvent({
    required String id,
    required String userId,
    required String eventName,
    required Map<String, dynamic> properties,
    DateTime? timestamp,
    String? appVersion,
  }) = _AnalyticsEvent;

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsEventFromJson(json);
}

@freezed
class AIMemory with _$AIMemory {
  const factory AIMemory({
    required String id,
    required String userId,
    required String memoryType,
    required String content,
    @Default(1) int importance,
    DateTime? createdAt,
  }) = _AIMemory;

  factory AIMemory.fromJson(Map<String, dynamic> json) =>
      _$AIMemoryFromJson(json);
}
