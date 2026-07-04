// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      requiredValue: (json['requiredValue'] as num?)?.toInt() ?? 0,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
      rarity: json['rarity'] as String? ?? '',
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'category': instance.category,
      'requiredValue': instance.requiredValue,
      'currentProgress': instance.currentProgress,
      'xpReward': instance.xpReward,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'rarity': instance.rarity,
    };

_$AchievementProgressImpl _$$AchievementProgressImplFromJson(
  Map<String, dynamic> json,
) => _$AchievementProgressImpl(
  achievementId: json['achievementId'] as String,
  currentValue: (json['currentValue'] as num?)?.toInt() ?? 0,
  targetValue: (json['targetValue'] as num?)?.toInt() ?? 0,
  percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$AchievementProgressImplToJson(
  _$AchievementProgressImpl instance,
) => <String, dynamic>{
  'achievementId': instance.achievementId,
  'currentValue': instance.currentValue,
  'targetValue': instance.targetValue,
  'percentage': instance.percentage,
};
