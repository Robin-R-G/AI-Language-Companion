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
  language: json['language'] as String,
  estimatedMinutes: (json['estimatedMinutes'] as num).toInt(),
  content: json['content'] as String?,
  quizzes: (json['quizzes'] as List<dynamic>?)
      ?.map((e) => LessonQuiz.fromJson(e as Map<String, dynamic>))
      .toList(),
  vocabulary: (json['vocabulary'] as List<dynamic>?)
      ?.map((e) => LessonVocabulary.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'difficulty': instance.difficulty,
      'language': instance.language,
      'estimatedMinutes': instance.estimatedMinutes,
      'content': instance.content,
      'quizzes': instance.quizzes,
      'vocabulary': instance.vocabulary,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$LessonQuizImpl _$$LessonQuizImplFromJson(Map<String, dynamic> json) =>
    _$LessonQuizImpl(
      questionId: json['questionId'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctOptionIndex: (json['correctOptionIndex'] as num).toInt(),
      explanation: json['explanation'] as String?,
    );

Map<String, dynamic> _$$LessonQuizImplToJson(_$LessonQuizImpl instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'question': instance.question,
      'options': instance.options,
      'correctOptionIndex': instance.correctOptionIndex,
      'explanation': instance.explanation,
    };

_$LessonVocabularyImpl _$$LessonVocabularyImplFromJson(
  Map<String, dynamic> json,
) => _$LessonVocabularyImpl(
  word: json['word'] as String,
  definition: json['definition'] as String,
  example: json['example'] as String?,
);

Map<String, dynamic> _$$LessonVocabularyImplToJson(
  _$LessonVocabularyImpl instance,
) => <String, dynamic>{
  'word': instance.word,
  'definition': instance.definition,
  'example': instance.example,
};

_$LessonProgressImpl _$$LessonProgressImplFromJson(Map<String, dynamic> json) =>
    _$LessonProgressImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      earnedXp: (json['earnedXp'] as num?)?.toInt() ?? 0,
      mistakes: json['mistakes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$LessonProgressImplToJson(
  _$LessonProgressImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'lessonId': instance.lessonId,
  'startedAt': instance.startedAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'completionPercentage': instance.completionPercentage,
  'earnedXp': instance.earnedXp,
  'mistakes': instance.mistakes,
};
