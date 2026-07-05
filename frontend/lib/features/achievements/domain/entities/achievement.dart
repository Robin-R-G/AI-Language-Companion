import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String userId,
    required String badgeId,
    required String title,
    required String description,
    required String iconName,
    required int xpReward,
    required String category,
    required String tier,
    required DateTime unlockedAt,
    required DateTime createdAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@freezed
abstract class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String name,
    required String description,
    required String iconName,
    required int xpReward,
    required String category,
    required String tier,
    required Map<String, dynamic> criteria,
    required bool isActive,
    required DateTime createdAt,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

@freezed
abstract class LeagueStanding with _$LeagueStanding {
  const factory LeagueStanding({
    required String userId,
    required String leagueId,
    required String leagueName,
    required int rank,
    required int xp,
    required int previousRank,
    required String tier,
    required DateTime weekStart,
    required DateTime weekEnd,
    required DateTime createdAt,
  }) = _LeagueStanding;

  factory LeagueStanding.fromJson(Map<String, dynamic> json) =>
      _$LeagueStandingFromJson(json);
}

@freezed
abstract class LeaderboardEntry with _$LeaderboardEntry {
  const factory LeaderboardEntry({
    required String userId,
    required String userName,
    required String? avatarUrl,
    required int rank,
    required int xp,
    required int streak,
    required int level,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
}

class AchievementProgress {
  final String achievementId;
  final int currentValue;
  final int targetValue;
  final double percentage;

  const AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    required this.targetValue,
    this.percentage = 0.0,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentValue: (json['currentValue'] as num?)?.toInt() ?? 0,
      targetValue: (json['targetValue'] as num).toInt(),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentValue': currentValue,
    'targetValue': targetValue,
    'percentage': percentage,
  };
}