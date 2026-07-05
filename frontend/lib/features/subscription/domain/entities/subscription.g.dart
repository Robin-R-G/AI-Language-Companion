// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: json['provider'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      status: json['status'] as String,
      billingCycle: json['billingCycle'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      currentPeriodStart: DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      trialEnd: json['trialEnd'] == null
          ? null
          : DateTime.parse(json['trialEnd'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'provider': instance.provider,
      'planId': instance.planId,
      'planName': instance.planName,
      'status': instance.status,
      'billingCycle': instance.billingCycle,
      'amount': instance.amount,
      'currency': instance.currency,
      'currentPeriodStart': instance.currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': instance.currentPeriodEnd.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'trialEnd': instance.trialEnd?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$SubscriptionPlanImpl _$$SubscriptionPlanImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionPlanImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
  annualPrice: (json['annualPrice'] as num).toDouble(),
  currency: json['currency'] as String,
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dailyVoiceMinutes: (json['dailyVoiceMinutes'] as num).toInt(),
  dailyLessons: (json['dailyLessons'] as num).toInt(),
  monthlyMockExams: (json['monthlyMockExams'] as num).toInt(),
  hasPrioritySupport: json['hasPrioritySupport'] as bool,
  hasAdvancedAnalytics: json['hasAdvancedAnalytics'] as bool,
  hasOfflineMode: json['hasOfflineMode'] as bool,
  isPopular: json['isPopular'] as bool,
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$SubscriptionPlanImplToJson(
  _$SubscriptionPlanImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'monthlyPrice': instance.monthlyPrice,
  'annualPrice': instance.annualPrice,
  'currency': instance.currency,
  'features': instance.features,
  'dailyVoiceMinutes': instance.dailyVoiceMinutes,
  'dailyLessons': instance.dailyLessons,
  'monthlyMockExams': instance.monthlyMockExams,
  'hasPrioritySupport': instance.hasPrioritySupport,
  'hasAdvancedAnalytics': instance.hasAdvancedAnalytics,
  'hasOfflineMode': instance.hasOfflineMode,
  'isPopular': instance.isPopular,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subscriptionId: json['subscriptionId'] as String,
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      platform: json['platform'] as String,
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'subscriptionId': instance.subscriptionId,
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'platform': instance.platform,
      'status': instance.status,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$EntitlementImpl _$$EntitlementImplFromJson(Map<String, dynamic> json) =>
    _$EntitlementImpl(
      userId: json['userId'] as String,
      isPremium: json['isPremium'] as bool,
      isPremiumPlus: json['isPremiumPlus'] as bool,
      dailyVoiceMinutesUsed: (json['dailyVoiceMinutesUsed'] as num).toInt(),
      dailyVoiceMinutesLimit: (json['dailyVoiceMinutesLimit'] as num).toInt(),
      dailyLessonsUsed: (json['dailyLessonsUsed'] as num).toInt(),
      dailyLessonsLimit: (json['dailyLessonsLimit'] as num).toInt(),
      monthlyMockExamsUsed: (json['monthlyMockExamsUsed'] as num).toInt(),
      monthlyMockExamsLimit: (json['monthlyMockExamsLimit'] as num).toInt(),
      lastResetDate: DateTime.parse(json['lastResetDate'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EntitlementImplToJson(_$EntitlementImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'isPremium': instance.isPremium,
      'isPremiumPlus': instance.isPremiumPlus,
      'dailyVoiceMinutesUsed': instance.dailyVoiceMinutesUsed,
      'dailyVoiceMinutesLimit': instance.dailyVoiceMinutesLimit,
      'dailyLessonsUsed': instance.dailyLessonsUsed,
      'dailyLessonsLimit': instance.dailyLessonsLimit,
      'monthlyMockExamsUsed': instance.monthlyMockExamsUsed,
      'monthlyMockExamsLimit': instance.monthlyMockExamsLimit,
      'lastResetDate': instance.lastResetDate.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
