import 'package:freezed_annotation/freezed_annotation.dart';

part 'mock_exam.freezed.dart';
part 'mock_exam.g.dart';

@freezed
abstract class MockExam with _$MockExam {
  const factory MockExam({
    required String id,
    required String userId,
    required String examType,
    required String section,
    required int durationMinutes,
    required int totalQuestions,
    required int questionsAnswered,
    required int correctAnswers,
    required double estimatedScore,
    required String status,
    required Map<String, dynamic> feedback,
    required DateTime startedAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MockExam;

  factory MockExam.fromJson(Map<String, dynamic> json) => _$MockExamFromJson(json);
}

@freezed
abstract class MockExamQuestion with _$MockExamQuestion {
  const factory MockExamQuestion({
    required String id,
    required String examId,
    required int questionNumber,
    required String questionType,
    required String prompt,
    required Map<String, dynamic> options,
    required String correctAnswer,
    String? userAnswer,
    required bool isCorrect,
    required DateTime createdAt,
  }) = _MockExamQuestion;

  factory MockExamQuestion.fromJson(Map<String, dynamic> json) =>
      _$MockExamQuestionFromJson(json);
}

@freezed
abstract class ExamSectionResult with _$ExamSectionResult {
  const factory ExamSectionResult({
    required String section,
    required double score,
    required String band,
    required Map<String, dynamic> details,
  }) = _ExamSectionResult;

  factory ExamSectionResult.fromJson(Map<String, dynamic> json) =>
      _$ExamSectionResultFromJson(json);
}