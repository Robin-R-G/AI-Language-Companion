// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamImpl _$$MockExamImplFromJson(Map<String, dynamic> json) =>
    _$MockExamImpl(
      id: json['id'] as String,
      examType: json['examType'] as String,
      section: json['section'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      answeredQuestions: (json['answeredQuestions'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'not_started',
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((e) => ExamQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bandScore: json['bandScore'] as String? ?? '',
    );

Map<String, dynamic> _$$MockExamImplToJson(_$MockExamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examType': instance.examType,
      'section': instance.section,
      'title': instance.title,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'totalQuestions': instance.totalQuestions,
      'answeredQuestions': instance.answeredQuestions,
      'score': instance.score,
      'status': instance.status,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'questions': instance.questions,
      'bandScore': instance.bandScore,
    };

_$ExamQuestionImpl _$$ExamQuestionImplFromJson(Map<String, dynamic> json) =>
    _$ExamQuestionImpl(
      id: json['id'] as String,
      question: json['question'] as String,
      type: json['type'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctAnswer: json['correctAnswer'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      timeSpentSeconds: (json['timeSpentSeconds'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );

Map<String, dynamic> _$$ExamQuestionImplToJson(_$ExamQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'type': instance.type,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'userAnswer': instance.userAnswer,
      'isCorrect': instance.isCorrect,
      'timeSpentSeconds': instance.timeSpentSeconds,
      'explanation': instance.explanation,
    };
