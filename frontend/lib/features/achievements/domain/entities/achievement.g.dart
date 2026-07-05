// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      badgeId: json['badgeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      category: json['category'] as String,
      tier: json['tier'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'badgeId': instance.badgeId,
      'title': instance.title,
      'description': instance.description,
      'iconName': instance.iconName,
      'xpReward': instance.xpReward,
      'category': instance.category,
      'tier': instance.tier,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  iconName: json['iconName'] as String,
  xpReward: (json['xpReward'] as num).toInt(),
  category: json['category'] as String,
  tier: json['tier'] as String,
  criteria: json['criteria'] as Map<String, dynamic>,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconName': instance.iconName,
      'xpReward': instance.xpReward,
      'category': instance.category,
      'tier': instance.tier,
      'criteria': instance.criteria,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$LeagueStandingImpl _$$LeagueStandingImplFromJson(Map<String, dynamic> json) =>
    _$LeagueStandingImpl(
      userId: json['userId'] as String,
      leagueId: json['leagueId'] as String,
      leagueName: json['leagueName'] as String,
      rank: (json['rank'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      previousRank: (json['previousRank'] as num).toInt(),
      tier: json['tier'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LeagueStandingImplToJson(
  _$LeagueStandingImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'leagueId': instance.leagueId,
  'leagueName': instance.leagueName,
  'rank': instance.rank,
  'xp': instance.xp,
  'previousRank': instance.previousRank,
  'tier': instance.tier,
  'weekStart': instance.weekStart.toIso8601String(),
  'weekEnd': instance.weekEnd.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

_$LeaderboardEntryImpl _$$LeaderboardEntryImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  rank: (json['rank'] as num).toInt(),
  xp: (json['xp'] as num).toInt(),
  streak: (json['streak'] as num).toInt(),
  level: (json['level'] as num).toInt(),
);

Map<String, dynamic> _$$LeaderboardEntryImplToJson(
  _$LeaderboardEntryImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'avatarUrl': instance.avatarUrl,
  'rank': instance.rank,
  'xp': instance.xp,
  'streak': instance.streak,
  'level': instance.level,
};
