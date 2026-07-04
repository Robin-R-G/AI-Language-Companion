// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      plan: json['plan'] as String,
      status: json['status'] as String,
      store: json['store'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      currentPeriodStart: json['currentPeriodStart'] == null
          ? null
          : DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: json['currentPeriodEnd'] == null
          ? null
          : DateTime.parse(json['currentPeriodEnd'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isTrial: json['isTrial'] as bool? ?? false,
      trialDaysRemaining: (json['trialDaysRemaining'] as num?)?.toInt() ?? 0,
      willRenew: json['willRenew'] as bool? ?? false,
      features: json['features'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'plan': instance.plan,
      'status': instance.status,
      'store': instance.store,
      'productId': instance.productId,
      'currentPeriodStart': instance.currentPeriodStart?.toIso8601String(),
      'currentPeriodEnd': instance.currentPeriodEnd?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'isTrial': instance.isTrial,
      'trialDaysRemaining': instance.trialDaysRemaining,
      'willRenew': instance.willRenew,
      'features': instance.features,
    };

_$SubscriptionPlanImpl _$$SubscriptionPlanImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionPlanImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  period: json['period'] as String,
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isPopular: json['isPopular'] as bool? ?? false,
  storeProductId: json['storeProductId'] as String? ?? '',
);

Map<String, dynamic> _$$SubscriptionPlanImplToJson(
  _$SubscriptionPlanImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'currency': instance.currency,
  'period': instance.period,
  'features': instance.features,
  'isPopular': instance.isPopular,
  'storeProductId': instance.storeProductId,
};
