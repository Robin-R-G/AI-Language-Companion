// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      tokenCount: (json['tokenCount'] as num?)?.toInt() ?? 0,
      latencyMs: (json['latencyMs'] as num?)?.toInt(),
      grammarFeedback: json['grammarFeedback'] as Map<String, dynamic>?,
      translation: json['translation'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'role': instance.role,
      'content': instance.content,
      'tokenCount': instance.tokenCount,
      'latencyMs': instance.latencyMs,
      'grammarFeedback': instance.grammarFeedback,
      'translation': instance.translation,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$AIConversationImpl _$$AIConversationImplFromJson(Map<String, dynamic> json) =>
    _$AIConversationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      model: json['model'] as String,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AIConversationImplToJson(
  _$AIConversationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'provider': instance.provider,
  'model': instance.model,
  'startedAt': instance.startedAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
