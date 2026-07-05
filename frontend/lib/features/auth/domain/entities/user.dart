import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? fullName,
    String? avatarUrl,
    required String nativeLanguage,
    required String targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    required bool onboardingCompleted,
    required int xp,
    required int level,
    required int streak,
    required int longestStreak,
    required DateTime lastActiveAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String email,
    String? fullName,
    String? avatarUrl,
    required String nativeLanguage,
    required String targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    required bool onboardingCompleted,
    required int xp,
    required int level,
    required int streak,
    required int longestStreak,
    required int dailyGoalMinutes,
    required DateTime? lastStudyDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
abstract class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    required String nativeLanguage,
    required String targetLanguage,
    required String proficiencyLevel,
    String? targetExam,
    required int dailyGoalMinutes,
    String? timezone,
  }) = _OnboardingData;

  factory OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);
}