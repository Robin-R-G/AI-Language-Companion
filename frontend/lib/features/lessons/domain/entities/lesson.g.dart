// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  language: json['language'] as String,
  level: json['level'] as String,
  order: (json['order'] as num).toInt(),
  xpReward: (json['xpReward'] as num).toInt(),
  estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  isLocked: json['isLocked'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'language': instance.language,
      'level': instance.level,
      'order': instance.order,
      'xpReward': instance.xpReward,
      'estimatedMinutes': instance.estimatedMinutes,
      'tags': instance.tags,
      'isLocked': instance.isLocked,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$LessonProgressImpl _$$LessonProgressImplFromJson(Map<String, dynamic> json) =>
    _$LessonProgressImpl(
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      isCompleted: json['isCompleted'] as bool,
      score: (json['score'] as num).toInt(),
      attempts: (json['attempts'] as num).toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$LessonProgressImplToJson(
  _$LessonProgressImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'lessonId': instance.lessonId,
  'isCompleted': instance.isCompleted,
  'score': instance.score,
  'attempts': instance.attempts,
  'completedAt': instance.completedAt?.toIso8601String(),
  'startedAt': instance.startedAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
