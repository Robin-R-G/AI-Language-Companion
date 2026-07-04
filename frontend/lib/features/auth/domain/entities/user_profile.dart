import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String authUserId,
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
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

extension UserProfileExtension on UserProfile {
  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    String? nativeLanguage,
    String? targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    bool? onboardingCompleted,
    int? xp,
    int? level,
    int? streak,
  }) {
    return UserProfile(
      id: id,
      authUserId: authUserId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      targetExam: targetExam ?? this.targetExam,
      timezone: timezone ?? this.timezone,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}