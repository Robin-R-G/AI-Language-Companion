// lib/shared/models/lesson.dart
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
    required String language,
    required int estimatedMinutes,
    String? content,
    List<LessonQuiz>? quizzes,
    List<LessonVocabulary>? vocabulary,
    DateTime? createdAt,
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
    String? explanation,
  }) = _LessonQuiz;

  factory LessonQuiz.fromJson(Map<String, dynamic> json) =>
      _$LessonQuizFromJson(json);
}

@freezed
class LessonVocabulary with _$LessonVocabulary {
  const factory LessonVocabulary({
    required String word,
    required String definition,
    String? example,
  }) = _LessonVocabulary;

  factory LessonVocabulary.fromJson(Map<String, dynamic> json) =>
      _$LessonVocabularyFromJson(json);
}

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String id,
    required String userId,
    required String lessonId,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default(0.0) double completionPercentage,
    @Default(0) int earnedXp,
    Map<String, dynamic>? mistakes,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressFromJson(json);
}
