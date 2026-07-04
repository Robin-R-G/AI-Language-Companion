import 'package:freezed_annotation/freezed_annotation.dart';

part 'mock_exam.freezed.dart';
part 'mock_exam.g.dart';

@freezed
class MockExam with _$MockExam {
  const factory MockExam({
    required String id,
    required String examType,
    required String section,
    required String title,
    @Default('') String description,
    @Default(0) int durationMinutes,
    @Default(0) int totalQuestions,
    @Default(0) int answeredQuestions,
    @Default(0.0) double score,
    @Default('not_started') String status,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default([]) List<ExamQuestion> questions,
    @Default('') String bandScore,
  }) = _MockExam;

  factory MockExam.fromJson(Map<String, dynamic> json) =>
      _$MockExamFromJson(json);
}

@freezed
class ExamQuestion with _$ExamQuestion {
  const factory ExamQuestion({
    required String id,
    required String question,
    required String type,
    @Default([]) List<String> options,
    @Default('') String correctAnswer,
    @Default('') String userAnswer,
    @Default(false) bool isCorrect,
    @Default(0) int timeSpentSeconds,
    @Default('') String explanation,
  }) = _ExamQuestion;

  factory ExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionFromJson(json);
}
