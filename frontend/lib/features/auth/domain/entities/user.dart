import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    @Default('') String displayName,
    @Default('') String avatarUrl,
    @Default('') String nativeLanguage,
    @Default('en') String targetLanguage,
    @Default('A1') String proficiencyLevel,
    @Default('general') String targetExam,
    @Default(0) int xp,
    @Default(0) int streak,
    @Default(0) int level,
    @Default(0) int lessonsCompleted,
    @Default(0) int voiceSessionsCompleted,
    @Default(0) int mockExamsCompleted,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    @Default(false) bool isOnboardingComplete,
    @Default(false) bool isPremium,
    @Default('free') String subscriptionPlan,
    @Default({}) Map<String, dynamic> preferences,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
