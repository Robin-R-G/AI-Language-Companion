// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  difficulty: json['difficulty'] as String,
  estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 15,
  content: json['content'] as String? ?? '',
  quizzes:
      (json['quizzes'] as List<dynamic>?)
          ?.map((e) => LessonQuiz.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  earnedXp: (json['earnedXp'] as num?)?.toInt() ?? 0,
  completionPercentage:
      (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
  startedAt: json['startedAt'] == null
      ? null
      : DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'estimatedMinutes': instance.estimatedMinutes,
      'content': instance.content,
      'quizzes': instance.quizzes,
      'earnedXp': instance.earnedXp,
      'completionPercentage': instance.completionPercentage,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$LessonQuizImpl _$$LessonQuizImplFromJson(Map<String, dynamic> json) =>
    _$LessonQuizImpl(
      questionId: json['questionId'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctOptionIndex: (json['correctOptionIndex'] as num).toInt(),
      explanation: json['explanation'] as String? ?? '',
    );

Map<String, dynamic> _$$LessonQuizImplToJson(_$LessonQuizImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'question': instance.question,
      'options': instance.options,
      'correctOptionIndex': instance.correctOptionIndex,
      'explanation': instance.explanation,
    };
