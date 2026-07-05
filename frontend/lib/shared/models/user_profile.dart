// lib/shared/models/user_profile.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String authUserId,
    required String fullName,
    String? avatarUrl,
    required String nativeLanguage,
    required String targetLanguage,
    required String proficiencyLevel,
    required String targetExam,
    @Default('UTC') String timezone,
    @Default(false) bool onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserGoals with _$UserGoals {
  const factory UserGoals({
    required String id,
    required String userId,
    @Default(20) int dailyGoal,
    @Default(140) int weeklyGoal,
    String? targetExamScore,
    String? reminderTime,
    DateTime? createdAt,
  }) = _UserGoals;

  factory UserGoals.fromJson(Map<String, dynamic> json) =>
      _$UserGoalsFromJson(json);
}

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String id,
    required String userId,
    @Default(0) int xp,
    @Default(1) int level,
    @Default(0) int grammarScore,
    @Default(0) int speakingScore,
    @Default(0) int writingScore,
    @Default(0) int vocabularyScore,
    @Default(0) int readingScore,
    @Default(0) int listeningScore,
    DateTime? lastStudyDate,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}

@freezed
class UserStreak with _$UserStreak {
  const factory UserStreak({
    required String id,
    required String userId,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int freezeCount,
    DateTime? lastActiveDate,
  }) = _UserStreak;

  factory UserStreak.fromJson(Map<String, dynamic> json) =>
      _$UserStreakFromJson(json);
}
