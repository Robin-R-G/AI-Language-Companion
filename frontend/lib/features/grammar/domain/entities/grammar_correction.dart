import 'package:freezed_annotation/freezed_annotation.dart';

part 'grammar_correction.freezed.dart';
part 'grammar_correction.g.dart';

@freezed
class GrammarCorrection with _$GrammarCorrection {
  const factory GrammarCorrection({
    required String id,
    required String originalText,
    required String correctedText,
    required String explanation,
    @Default('') String explanationMalayalam,
    @Default('') String category,
    @Default('medium') String severity,
    @Default([]) List<String> suggestions,
    @Default([]) List<String> relatedRules,
    DateTime? createdAt,
    @Default(0) int startIndex,
    @Default(0) int endIndex,
  }) = _GrammarCorrection;

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) =>
      _$GrammarCorrectionFromJson(json);
}
