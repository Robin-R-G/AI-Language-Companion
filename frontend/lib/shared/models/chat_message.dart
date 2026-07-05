// lib/shared/models/chat_message.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    @Default(0) int tokenCount,
    int? latencyMs,
    Map<String, dynamic>? grammarFeedback,
    String? translation,
    DateTime? timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class AIConversation with _$AIConversation {
  const factory AIConversation({
    required String id,
    required String userId,
    required String title,
    required String provider,
    required String model,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) = _AIConversation;

  factory AIConversation.fromJson(Map<String, dynamic> json) =>
      _$AIConversationFromJson(json);
}
