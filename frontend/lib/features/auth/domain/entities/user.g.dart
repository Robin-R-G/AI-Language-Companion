// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      nativeLanguage: json['nativeLanguage'] as String? ?? '',
      targetLanguage: json['targetLanguage'] as String? ?? 'en',
      proficiencyLevel: json['proficiencyLevel'] as String? ?? 'A1',
      targetExam: json['targetExam'] as String? ?? 'general',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (json['lessonsCompleted'] as num?)?.toInt() ?? 0,
      voiceSessionsCompleted:
          (json['voiceSessionsCompleted'] as num?)?.toInt() ?? 0,
      mockExamsCompleted: (json['mockExamsCompleted'] as num?)?.toInt() ?? 0,
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'nativeLanguage': instance.nativeLanguage,
      'targetLanguage': instance.targetLanguage,
      'proficiencyLevel': instance.proficiencyLevel,
      'targetExam': instance.targetExam,
      'xp': instance.xp,
      'streak': instance.streak,
      'level': instance.level,
      'lessonsCompleted': instance.lessonsCompleted,
      'voiceSessionsCompleted': instance.voiceSessionsCompleted,
      'mockExamsCompleted': instance.mockExamsCompleted,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'isOnboardingComplete': instance.isOnboardingComplete,
      'isPremium': instance.isPremium,
      'subscriptionPlan': instance.subscriptionPlan,
      'preferences': instance.preferences,
    };
