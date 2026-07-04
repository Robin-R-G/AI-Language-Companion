import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String role,
    required String content,
    DateTime? timestamp,
    GrammarFeedback? grammarFeedback,
    TranslationData? translation,
    int? tokenCount,
    int? latencyMs,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class GrammarFeedback with _$GrammarFeedback {
  const factory GrammarFeedback({
    @Default(false) bool isCorrect,
    required String original,
    required String corrected,
    required String explanation,
    @Default('') String explanationMalayalam,
    @Default('') String category,
    @Default([]) List<String> examples,
  }) = _GrammarFeedback;

  factory GrammarFeedback.fromJson(Map<String, dynamic> json) =>
      _$GrammarFeedbackFromJson(json);
}

@freezed
class TranslationData with _$TranslationData {
  const factory TranslationData({
    required String translation,
    @Default('') String pronunciation,
    Map<String, String>? alternativeExpressions,
    @Default('') String explanation,
  }) = _TranslationData;

  factory TranslationData.fromJson(Map<String, dynamic> json) =>
      _$TranslationDataFromJson(json);
}
