// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MockExamImpl _$$MockExamImplFromJson(Map<String, dynamic> json) =>
    _$MockExamImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      examType: json['examType'] as String,
      section: json['section'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      questionsAnswered: (json['questionsAnswered'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      estimatedScore: (json['estimatedScore'] as num).toDouble(),
      status: json['status'] as String,
      feedback: json['feedback'] as Map<String, dynamic>,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MockExamImplToJson(_$MockExamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'examType': instance.examType,
      'section': instance.section,
      'durationMinutes': instance.durationMinutes,
      'totalQuestions': instance.totalQuestions,
      'questionsAnswered': instance.questionsAnswered,
      'correctAnswers': instance.correctAnswers,
      'estimatedScore': instance.estimatedScore,
      'status': instance.status,
      'feedback': instance.feedback,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$MockExamQuestionImpl _$$MockExamQuestionImplFromJson(
  Map<String, dynamic> json,
) => _$MockExamQuestionImpl(
  id: json['id'] as String,
  examId: json['examId'] as String,
  questionNumber: (json['questionNumber'] as num).toInt(),
  questionType: json['questionType'] as String,
  prompt: json['prompt'] as String,
  options: json['options'] as Map<String, dynamic>,
  correctAnswer: json['correctAnswer'] as String,
  userAnswer: json['userAnswer'] as String?,
  isCorrect: json['isCorrect'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MockExamQuestionImplToJson(
  _$MockExamQuestionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'examId': instance.examId,
  'questionNumber': instance.questionNumber,
  'questionType': instance.questionType,
  'prompt': instance.prompt,
  'options': instance.options,
  'correctAnswer': instance.correctAnswer,
  'userAnswer': instance.userAnswer,
  'isCorrect': instance.isCorrect,
  'createdAt': instance.createdAt.toIso8601String(),
};

_$ExamSectionResultImpl _$$ExamSectionResultImplFromJson(
  Map<String, dynamic> json,
) => _$ExamSectionResultImpl(
  section: json['section'] as String,
  score: (json['score'] as num).toDouble(),
  band: json['band'] as String,
  details: json['details'] as Map<String, dynamic>,
);

Map<String, dynamic> _$$ExamSectionResultImplToJson(
  _$ExamSectionResultImpl instance,
) => <String, dynamic>{
  'section': instance.section,
  'score': instance.score,
  'band': instance.band,
  'details': instance.details,
};
