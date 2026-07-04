import 'package:freezed_annotation/freezed_annotation.dart';

part 'writing_evaluation.freezed.dart';
part 'writing_evaluation.g.dart';

@freezed
class WritingEvaluation with _$WritingEvaluation {
  const factory WritingEvaluation({
    @Default('') String estimatedBand,
    @Default(0) int grammarScore,
    @Default(0) int vocabularyScore,
    @Default(0) int organizationScore,
    @Default(0) int clarityScore,
    @Default([]) List<String> strengths,
    @Default([]) List<String> mistakes,
    @Default('') String improvedVersion,
    @Default([]) List<String> recommendations,
  }) = _WritingEvaluation;

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) =>
      _$WritingEvaluationFromJson(json);
}
