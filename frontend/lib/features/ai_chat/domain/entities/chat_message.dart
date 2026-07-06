// lib/features/ai_chat/domain/entities/chat_message.dart
// Re-exports the shared ChatMessage model for feature-level access.
export '../../../../shared/models/chat_message.dart'
    show ChatMessage, AIConversation;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Feature-specific grammar feedback entity used by AI chat.
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

/// Feature-specific translation data entity used by AI chat.
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
