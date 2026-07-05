// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      achievementName: json['achievementName'] as String,
      badge: json['badge'] as String,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'achievementName': instance.achievementName,
      'badge': instance.badge,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'xpReward': instance.xpReward,
    };

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      provider: json['provider'] as String,
      plan: json['plan'] as String,
      status: json['status'] as String,
      renewalDate: json['renewalDate'] == null
          ? null
          : DateTime.parse(json['renewalDate'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'provider': instance.provider,
      'plan': instance.plan,
      'status': instance.status,
      'renewalDate': instance.renewalDate?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      platform: json['platform'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'platform': instance.platform,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$NotificationImpl _$$NotificationImplFromJson(Map<String, dynamic> json) =>
    _$NotificationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$$NotificationImplToJson(_$NotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'sentAt': instance.sentAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

_$AnalyticsEventImpl _$$AnalyticsEventImplFromJson(Map<String, dynamic> json) =>
    _$AnalyticsEventImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventName: json['eventName'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      appVersion: json['appVersion'] as String?,
    );

Map<String, dynamic> _$$AnalyticsEventImplToJson(
  _$AnalyticsEventImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'eventName': instance.eventName,
  'properties': instance.properties,
  'timestamp': instance.timestamp?.toIso8601String(),
  'appVersion': instance.appVersion,
};

_$AIMemoryImpl _$$AIMemoryImplFromJson(Map<String, dynamic> json) =>
    _$AIMemoryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      memoryType: json['memoryType'] as String,
      content: json['content'] as String,
      importance: (json['importance'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AIMemoryImplToJson(_$AIMemoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'memoryType': instance.memoryType,
      'content': instance.content,
      'importance': instance.importance,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
