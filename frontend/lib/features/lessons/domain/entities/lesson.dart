import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required String title,
    required String description,
    required String language,
    required String level,
    required int order,
    required int xpReward,
    required int estimatedMinutes,
    required List<String> tags,
    required bool isLocked,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

@freezed
abstract class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String userId,
    required String lessonId,
    required bool isCompleted,
    required int score,
    required int attempts,
    required DateTime? completedAt,
    required DateTime startedAt,
    required DateTime updatedAt,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressFromJson(json);
}