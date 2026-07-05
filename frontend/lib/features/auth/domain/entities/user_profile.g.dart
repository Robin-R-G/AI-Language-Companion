// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      authUserId: json['authUserId'] as String,
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
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'xp': instance.xp,
      'level': instance.level,
      'streak': instance.streak,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
