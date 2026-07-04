import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String plan,
    required String status,
    @Default('') String store,
    @Default('') String productId,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
    @Default(false) bool isTrial,
    @Default(0) int trialDaysRemaining,
    @Default(false) bool willRenew,
    @Default({}) Map<String, dynamic> features,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required String description,
    required double price,
    required String currency,
    required String period,
    @Default([]) List<String> features,
    @Default(false) bool isPopular,
    @Default('') String storeProductId,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanFromJson(json);
}
