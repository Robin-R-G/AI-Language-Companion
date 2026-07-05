import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

@freezed
abstract class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String provider,
    required String planId,
    required String planName,
    required String status,
    required String billingCycle,
    required double amount,
    required String currency,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    DateTime? cancelledAt,
    DateTime? trialEnd,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
abstract class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required String description,
    required double monthlyPrice,
    required double annualPrice,
    required String currency,
    required List<String> features,
    required int dailyVoiceMinutes,
    required int dailyLessons,
    required int monthlyMockExams,
    required bool hasPrioritySupport,
    required bool hasAdvancedAnalytics,
    required bool hasOfflineMode,
    required bool isPopular,
    required int sortOrder,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String userId,
    required String subscriptionId,
    required String transactionId,
    required double amount,
    required String currency,
    required String platform,
    required String status,
    required Map<String, dynamic> metadata,
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}

@freezed
abstract class Entitlement with _$Entitlement {
  const factory Entitlement({
    required String userId,
    required bool isPremium,
    required bool isPremiumPlus,
    required int dailyVoiceMinutesUsed,
    required int dailyVoiceMinutesLimit,
    required int dailyLessonsUsed,
    required int dailyLessonsLimit,
    required int monthlyMockExamsUsed,
    required int monthlyMockExamsLimit,
    required DateTime lastResetDate,
    required DateTime updatedAt,
  }) = _Entitlement;

  factory Entitlement.fromJson(Map<String, dynamic> json) =>
      _$EntitlementFromJson(json);
}