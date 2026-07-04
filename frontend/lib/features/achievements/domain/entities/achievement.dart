import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String icon,
    required String category,
    @Default(0) int requiredValue,
    @Default(0) int currentProgress,
    @Default(0) int xpReward,
    @Default(false) bool isUnlocked,
    DateTime? unlockedAt,
    @Default('') String rarity,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

@freezed
class AchievementProgress with _$AchievementProgress {
  const factory AchievementProgress({
    required String achievementId,
    @Default(0) int currentValue,
    @Default(0) int targetValue,
    @Default(0.0) double percentage,
  }) = _AchievementProgress;

  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressFromJson(json);
}
