// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      nativeLanguage: json['nativeLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      targetExam: json['targetExam'] as String?,
      timezone: json['timezone'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool,
      xp: (json['xp'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'nativeLanguage': instance.nativeLanguage,
      'targetLanguage': instance.targetLanguage,
      'proficiencyLevel': instance.proficiencyLevel,
      'targetExam': instance.targetExam,
      'timezone': instance.timezone,
      'onboardingCompleted': instance.onboardingCompleted,
      'xp': instance.xp,
      'level': instance.level,
      'streak': instance.streak,
      'longestStreak': instance.longestStreak,
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      nativeLanguage: json['nativeLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      proficiencyLevel: json['proficiencyLevel'] as String?,
      targetExam: json['targetExam'] as String?,
      timezone: json['timezone'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool,
      xp: (json['xp'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num).toInt(),
      lastStudyDate: json['lastStudyDate'] == null
          ? null
          : DateTime.parse(json['lastStudyDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'nativeLanguage': instance.nativeLanguage,
      'targetLanguage': instance.targetLanguage,
      'proficiencyLevel': instance.proficiencyLevel,
      'targetExam': instance.targetExam,
      'timezone': instance.timezone,
      'onboardingCompleted': instance.onboardingCompleted,
      'xp': instance.xp,
      'level': instance.level,
      'streak': instance.streak,
      'longestStreak': instance.longestStreak,
      'dailyGoalMinutes': instance.dailyGoalMinutes,
      'lastStudyDate': instance.lastStudyDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$OnboardingDataImpl _$$OnboardingDataImplFromJson(Map<String, dynamic> json) =>
    _$OnboardingDataImpl(
      nativeLanguage: json['nativeLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      proficiencyLevel: json['proficiencyLevel'] as String,
      targetExam: json['targetExam'] as String?,
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num).toInt(),
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$$OnboardingDataImplToJson(
  _$OnboardingDataImpl instance,
) => <String, dynamic>{
  'nativeLanguage': instance.nativeLanguage,
  'targetLanguage': instance.targetLanguage,
  'proficiencyLevel': instance.proficiencyLevel,
  'targetExam': instance.targetExam,
  'dailyGoalMinutes': instance.dailyGoalMinutes,
  'timezone': instance.timezone,
};
