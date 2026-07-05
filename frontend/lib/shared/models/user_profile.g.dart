// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      authUserId: json['authUserId'] as String,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      nativeLanguage: json['nativeLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      proficiencyLevel: json['proficiencyLevel'] as String,
      targetExam: json['targetExam'] as String,
      timezone: json['timezone'] as String? ?? 'UTC',
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authUserId': instance.authUserId,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'nativeLanguage': instance.nativeLanguage,
      'targetLanguage': instance.targetLanguage,
      'proficiencyLevel': instance.proficiencyLevel,
      'targetExam': instance.targetExam,
      'timezone': instance.timezone,
      'onboardingCompleted': instance.onboardingCompleted,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$UserGoalsImpl _$$UserGoalsImplFromJson(Map<String, dynamic> json) =>
    _$UserGoalsImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 20,
      weeklyGoal: (json['weeklyGoal'] as num?)?.toInt() ?? 140,
      targetExamScore: json['targetExamScore'] as String?,
      reminderTime: json['reminderTime'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserGoalsImplToJson(_$UserGoalsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dailyGoal': instance.dailyGoal,
      'weeklyGoal': instance.weeklyGoal,
      'targetExamScore': instance.targetExamScore,
      'reminderTime': instance.reminderTime,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      grammarScore: (json['grammarScore'] as num?)?.toInt() ?? 0,
      speakingScore: (json['speakingScore'] as num?)?.toInt() ?? 0,
      writingScore: (json['writingScore'] as num?)?.toInt() ?? 0,
      vocabularyScore: (json['vocabularyScore'] as num?)?.toInt() ?? 0,
      readingScore: (json['readingScore'] as num?)?.toInt() ?? 0,
      listeningScore: (json['listeningScore'] as num?)?.toInt() ?? 0,
      lastStudyDate: json['lastStudyDate'] == null
          ? null
          : DateTime.parse(json['lastStudyDate'] as String),
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'xp': instance.xp,
      'level': instance.level,
      'grammarScore': instance.grammarScore,
      'speakingScore': instance.speakingScore,
      'writingScore': instance.writingScore,
      'vocabularyScore': instance.vocabularyScore,
      'readingScore': instance.readingScore,
      'listeningScore': instance.listeningScore,
      'lastStudyDate': instance.lastStudyDate?.toIso8601String(),
    };

_$UserStreakImpl _$$UserStreakImplFromJson(Map<String, dynamic> json) =>
    _$UserStreakImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      freezeCount: (json['freezeCount'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate'] == null
          ? null
          : DateTime.parse(json['lastActiveDate'] as String),
    );

Map<String, dynamic> _$$UserStreakImplToJson(_$UserStreakImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'freezeCount': instance.freezeCount,
      'lastActiveDate': instance.lastActiveDate?.toIso8601String(),
    };
