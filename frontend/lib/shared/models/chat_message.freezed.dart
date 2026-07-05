// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  int get tokenCount => throw _privateConstructorUsedError;
  int? get latencyMs => throw _privateConstructorUsedError;
  Map<String, dynamic>? get grammarFeedback =>
      throw _privateConstructorUsedError;
  String? get translation => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String conversationId,
    String role,
    String content,
    int tokenCount,
    int? latencyMs,
    Map<String, dynamic>? grammarFeedback,
    String? translation,
    DateTime? timestamp,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? role = null,
    Object? content = null,
    Object? tokenCount = null,
    Object? latencyMs = freezed,
    Object? grammarFeedback = freezed,
    Object? translation = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            tokenCount: null == tokenCount
                ? _value.tokenCount
                : tokenCount // ignore: cast_nullable_to_non_nullable
                      as int,
            latencyMs: freezed == latencyMs
                ? _value.latencyMs
                : latencyMs // ignore: cast_nullable_to_non_nullable
                      as int?,
            grammarFeedback: freezed == grammarFeedback
                ? _value.grammarFeedback
                : grammarFeedback // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            translation: freezed == translation
                ? _value.translation
                : translation // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: freezed == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String conversationId,
    String role,
    String content,
    int tokenCount,
    int? latencyMs,
    Map<String, dynamic>? grammarFeedback,
    String? translation,
    DateTime? timestamp,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? role = null,
    Object? content = null,
    Object? tokenCount = null,
    Object? latencyMs = freezed,
    Object? grammarFeedback = freezed,
    Object? translation = freezed,
    Object? timestamp = freezed,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        tokenCount: null == tokenCount
            ? _value.tokenCount
            : tokenCount // ignore: cast_nullable_to_non_nullable
                  as int,
        latencyMs: freezed == latencyMs
            ? _value.latencyMs
            : latencyMs // ignore: cast_nullable_to_non_nullable
                  as int?,
        grammarFeedback: freezed == grammarFeedback
            ? _value._grammarFeedback
            : grammarFeedback // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        translation: freezed == translation
            ? _value.translation
            : translation // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: freezed == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.tokenCount = 0,
    this.latencyMs,
    final Map<String, dynamic>? grammarFeedback,
    this.translation,
    this.timestamp,
  }) : _grammarFeedback = grammarFeedback;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String role;
  @override
  final String content;
  @override
  @JsonKey()
  final int tokenCount;
  @override
  final int? latencyMs;
  final Map<String, dynamic>? _grammarFeedback;
  @override
  Map<String, dynamic>? get grammarFeedback {
    final value = _grammarFeedback;
    if (value == null) return null;
    if (_grammarFeedback is EqualUnmodifiableMapView) return _grammarFeedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? translation;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'ChatMessage(id: $id, conversationId: $conversationId, role: $role, content: $content, tokenCount: $tokenCount, latencyMs: $latencyMs, grammarFeedback: $grammarFeedback, translation: $translation, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.tokenCount, tokenCount) ||
                other.tokenCount == tokenCount) &&
            (identical(other.latencyMs, latencyMs) ||
                other.latencyMs == latencyMs) &&
            const DeepCollectionEquality().equals(
              other._grammarFeedback,
              _grammarFeedback,
            ) &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    conversationId,
    role,
    content,
    tokenCount,
    latencyMs,
    const DeepCollectionEquality().hash(_grammarFeedback),
    translation,
    timestamp,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String conversationId,
    required final String role,
    required final String content,
    final int tokenCount,
    final int? latencyMs,
    final Map<String, dynamic>? grammarFeedback,
    final String? translation,
    final DateTime? timestamp,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get role;
  @override
  String get content;
  @override
  int get tokenCount;
  @override
  int? get latencyMs;
  @override
  Map<String, dynamic>? get grammarFeedback;
  @override
  String? get translation;
  @override
  DateTime? get timestamp;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIConversation _$AIConversationFromJson(Map<String, dynamic> json) {
  return _AIConversation.fromJson(json);
}

/// @nodoc
mixin _$AIConversation {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AIConversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConversationCopyWith<AIConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConversationCopyWith<$Res> {
  factory $AIConversationCopyWith(
    AIConversation value,
    $Res Function(AIConversation) then,
  ) = _$AIConversationCopyWithImpl<$Res, AIConversation>;
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String provider,
    String model,
    DateTime? startedAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$AIConversationCopyWithImpl<$Res, $Val extends AIConversation>
    implements $AIConversationCopyWith<$Res> {
  _$AIConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? provider = null,
    Object? model = null,
    Object? startedAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            model: null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AIConversationImplCopyWith<$Res>
    implements $AIConversationCopyWith<$Res> {
  factory _$$AIConversationImplCopyWith(
    _$AIConversationImpl value,
    $Res Function(_$AIConversationImpl) then,
  ) = __$$AIConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String title,
    String provider,
    String model,
    DateTime? startedAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AIConversationImplCopyWithImpl<$Res>
    extends _$AIConversationCopyWithImpl<$Res, _$AIConversationImpl>
    implements _$$AIConversationImplCopyWith<$Res> {
  __$$AIConversationImplCopyWithImpl(
    _$AIConversationImpl _value,
    $Res Function(_$AIConversationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? provider = null,
    Object? model = null,
    Object? startedAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AIConversationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        model: null == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AIConversationImpl implements _AIConversation {
  const _$AIConversationImpl({
    required this.id,
    required this.userId,
    required this.title,
    required this.provider,
    required this.model,
    this.startedAt,
    this.updatedAt,
  });

  factory _$AIConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String provider;
  @override
  final String model;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AIConversation(id: $id, userId: $userId, title: $title, provider: $provider, model: $model, startedAt: $startedAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    title,
    provider,
    model,
    startedAt,
    updatedAt,
  );

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConversationImplCopyWith<_$AIConversationImpl> get copyWith =>
      __$$AIConversationImplCopyWithImpl<_$AIConversationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AIConversationImplToJson(this);
  }
}

abstract class _AIConversation implements AIConversation {
  const factory _AIConversation({
    required final String id,
    required final String userId,
    required final String title,
    required final String provider,
    required final String model,
    final DateTime? startedAt,
    final DateTime? updatedAt,
  }) = _$AIConversationImpl;

  factory _AIConversation.fromJson(Map<String, dynamic> json) =
      _$AIConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  String get provider;
  @override
  String get model;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AIConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConversationImplCopyWith<_$AIConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
