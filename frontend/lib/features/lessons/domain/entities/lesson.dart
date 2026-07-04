import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required String title,
    required String category,
    required String difficulty,
    @Default(15) int estimatedMinutes,
    @Default('') String content,
    @Default([]) List<LessonQuiz> quizzes,
    @Default(0) int earnedXp,
    @Default(0.0) double completionPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) =>
      _$LessonFromJson(json);
}

@freezed
class LessonQuiz with _$LessonQuiz {
  const factory LessonQuiz({
    required String questionId,
    required String question,
    required List<String> options,
    required int correctOptionIndex,
    @Default('') String explanation,
  }) = _LessonQuiz;

  factory LessonQuiz.fromJson(Map<String, dynamic> json) =>
      _$LessonQuizFromJson(json);
}
