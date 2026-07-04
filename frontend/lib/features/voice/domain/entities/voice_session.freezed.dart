// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VoiceSession _$VoiceSessionFromJson(Map<String, dynamic> json) {
  return _VoiceSession.fromJson(json);
}

/// @nodoc
mixin _$VoiceSession {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  int get averageLatencyMs => throw _privateConstructorUsedError;
  int get overallScore => throw _privateConstructorUsedError;
  String get transcriptText => throw _privateConstructorUsedError;

  /// Serializes this VoiceSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceSessionCopyWith<VoiceSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceSessionCopyWith<$Res> {
  factory $VoiceSessionCopyWith(
    VoiceSession value,
    $Res Function(VoiceSession) then,
  ) = _$VoiceSessionCopyWithImpl<$Res, VoiceSession>;
  @useResult
  $Res call({
    String id,
    String userId,
    String provider,
    int durationSeconds,
    String roomId,
    DateTime? startedAt,
    DateTime? endedAt,
    int averageLatencyMs,
    int overallScore,
    String transcriptText,
  });
}

/// @nodoc
class _$VoiceSessionCopyWithImpl<$Res, $Val extends VoiceSession>
    implements $VoiceSessionCopyWith<$Res> {
  _$VoiceSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? provider = null,
    Object? durationSeconds = null,
    Object? roomId = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? averageLatencyMs = null,
    Object? overallScore = null,
    Object? transcriptText = null,
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
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            roomId: null == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            averageLatencyMs: null == averageLatencyMs
                ? _value.averageLatencyMs
                : averageLatencyMs // ignore: cast_nullable_to_non_nullable
                      as int,
            overallScore: null == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as int,
            transcriptText: null == transcriptText
                ? _value.transcriptText
                : transcriptText // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoiceSessionImplCopyWith<$Res>
    implements $VoiceSessionCopyWith<$Res> {
  factory _$$VoiceSessionImplCopyWith(
    _$VoiceSessionImpl value,
    $Res Function(_$VoiceSessionImpl) then,
  ) = __$$VoiceSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String provider,
    int durationSeconds,
    String roomId,
    DateTime? startedAt,
    DateTime? endedAt,
    int averageLatencyMs,
    int overallScore,
    String transcriptText,
  });
}

/// @nodoc
class __$$VoiceSessionImplCopyWithImpl<$Res>
    extends _$VoiceSessionCopyWithImpl<$Res, _$VoiceSessionImpl>
    implements _$$VoiceSessionImplCopyWith<$Res> {
  __$$VoiceSessionImplCopyWithImpl(
    _$VoiceSessionImpl _value,
    $Res Function(_$VoiceSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoiceSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? provider = null,
    Object? durationSeconds = null,
    Object? roomId = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? averageLatencyMs = null,
    Object? overallScore = null,
    Object? transcriptText = null,
  }) {
    return _then(
      _$VoiceSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        roomId: null == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        averageLatencyMs: null == averageLatencyMs
            ? _value.averageLatencyMs
            : averageLatencyMs // ignore: cast_nullable_to_non_nullable
                  as int,
        overallScore: null == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as int,
        transcriptText: null == transcriptText
            ? _value.transcriptText
            : transcriptText // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceSessionImpl implements _VoiceSession {
  const _$VoiceSessionImpl({
    required this.id,
    required this.userId,
    this.provider = '',
    this.durationSeconds = 0,
    this.roomId = '',
    this.startedAt,
    this.endedAt,
    this.averageLatencyMs = 0,
    this.overallScore = 0,
    this.transcriptText = '',
  });

  factory _$VoiceSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final String provider;
  @override
  @JsonKey()
  final int durationSeconds;
  @override
  @JsonKey()
  final String roomId;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  @JsonKey()
  final int averageLatencyMs;
  @override
  @JsonKey()
  final int overallScore;
  @override
  @JsonKey()
  final String transcriptText;

  @override
  String toString() {
    return 'VoiceSession(id: $id, userId: $userId, provider: $provider, durationSeconds: $durationSeconds, roomId: $roomId, startedAt: $startedAt, endedAt: $endedAt, averageLatencyMs: $averageLatencyMs, overallScore: $overallScore, transcriptText: $transcriptText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.averageLatencyMs, averageLatencyMs) ||
                other.averageLatencyMs == averageLatencyMs) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.transcriptText, transcriptText) ||
                other.transcriptText == transcriptText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    provider,
    durationSeconds,
    roomId,
    startedAt,
    endedAt,
    averageLatencyMs,
    overallScore,
    transcriptText,
  );

  /// Create a copy of VoiceSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceSessionImplCopyWith<_$VoiceSessionImpl> get copyWith =>
      __$$VoiceSessionImplCopyWithImpl<_$VoiceSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceSessionImplToJson(this);
  }
}

abstract class _VoiceSession implements VoiceSession {
  const factory _VoiceSession({
    required final String id,
    required final String userId,
    final String provider,
    final int durationSeconds,
    final String roomId,
    final DateTime? startedAt,
    final DateTime? endedAt,
    final int averageLatencyMs,
    final int overallScore,
    final String transcriptText,
  }) = _$VoiceSessionImpl;

  factory _VoiceSession.fromJson(Map<String, dynamic> json) =
      _$VoiceSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get provider;
  @override
  int get durationSeconds;
  @override
  String get roomId;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;
  @override
  int get averageLatencyMs;
  @override
  int get overallScore;
  @override
  String get transcriptText;

  /// Create a copy of VoiceSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceSessionImplCopyWith<_$VoiceSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PronunciationScore _$PronunciationScoreFromJson(Map<String, dynamic> json) {
  return _PronunciationScore.fromJson(json);
}

/// @nodoc
mixin _$PronunciationScore {
  int get fluencyScore => throw _privateConstructorUsedError;
  int get grammarScore => throw _privateConstructorUsedError;
  int get vocabularyScore => throw _privateConstructorUsedError;
  int get pronunciationScore => throw _privateConstructorUsedError;
  int get overallScore => throw _privateConstructorUsedError;
  String get feedback => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get issues => throw _privateConstructorUsedError;
  List<String> get practiceWords => throw _privateConstructorUsedError;
  String get shadowingExercise => throw _privateConstructorUsedError;
  String get estimatedProficiency => throw _privateConstructorUsedError;

  /// Serializes this PronunciationScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PronunciationScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PronunciationScoreCopyWith<PronunciationScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PronunciationScoreCopyWith<$Res> {
  factory $PronunciationScoreCopyWith(
    PronunciationScore value,
    $Res Function(PronunciationScore) then,
  ) = _$PronunciationScoreCopyWithImpl<$Res, PronunciationScore>;
  @useResult
  $Res call({
    int fluencyScore,
    int grammarScore,
    int vocabularyScore,
    int pronunciationScore,
    int overallScore,
    String feedback,
    List<String> strengths,
    List<String> issues,
    List<String> practiceWords,
    String shadowingExercise,
    String estimatedProficiency,
  });
}

/// @nodoc
class _$PronunciationScoreCopyWithImpl<$Res, $Val extends PronunciationScore>
    implements $PronunciationScoreCopyWith<$Res> {
  _$PronunciationScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PronunciationScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fluencyScore = null,
    Object? grammarScore = null,
    Object? vocabularyScore = null,
    Object? pronunciationScore = null,
    Object? overallScore = null,
    Object? feedback = null,
    Object? strengths = null,
    Object? issues = null,
    Object? practiceWords = null,
    Object? shadowingExercise = null,
    Object? estimatedProficiency = null,
  }) {
    return _then(
      _value.copyWith(
            fluencyScore: null == fluencyScore
                ? _value.fluencyScore
                : fluencyScore // ignore: cast_nullable_to_non_nullable
                      as int,
            grammarScore: null == grammarScore
                ? _value.grammarScore
                : grammarScore // ignore: cast_nullable_to_non_nullable
                      as int,
            vocabularyScore: null == vocabularyScore
                ? _value.vocabularyScore
                : vocabularyScore // ignore: cast_nullable_to_non_nullable
                      as int,
            pronunciationScore: null == pronunciationScore
                ? _value.pronunciationScore
                : pronunciationScore // ignore: cast_nullable_to_non_nullable
                      as int,
            overallScore: null == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as int,
            feedback: null == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as String,
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            issues: null == issues
                ? _value.issues
                : issues // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            practiceWords: null == practiceWords
                ? _value.practiceWords
                : practiceWords // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            shadowingExercise: null == shadowingExercise
                ? _value.shadowingExercise
                : shadowingExercise // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedProficiency: null == estimatedProficiency
                ? _value.estimatedProficiency
                : estimatedProficiency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PronunciationScoreImplCopyWith<$Res>
    implements $PronunciationScoreCopyWith<$Res> {
  factory _$$PronunciationScoreImplCopyWith(
    _$PronunciationScoreImpl value,
    $Res Function(_$PronunciationScoreImpl) then,
  ) = __$$PronunciationScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int fluencyScore,
    int grammarScore,
    int vocabularyScore,
    int pronunciationScore,
    int overallScore,
    String feedback,
    List<String> strengths,
    List<String> issues,
    List<String> practiceWords,
    String shadowingExercise,
    String estimatedProficiency,
  });
}

/// @nodoc
class __$$PronunciationScoreImplCopyWithImpl<$Res>
    extends _$PronunciationScoreCopyWithImpl<$Res, _$PronunciationScoreImpl>
    implements _$$PronunciationScoreImplCopyWith<$Res> {
  __$$PronunciationScoreImplCopyWithImpl(
    _$PronunciationScoreImpl _value,
    $Res Function(_$PronunciationScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PronunciationScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fluencyScore = null,
    Object? grammarScore = null,
    Object? vocabularyScore = null,
    Object? pronunciationScore = null,
    Object? overallScore = null,
    Object? feedback = null,
    Object? strengths = null,
    Object? issues = null,
    Object? practiceWords = null,
    Object? shadowingExercise = null,
    Object? estimatedProficiency = null,
  }) {
    return _then(
      _$PronunciationScoreImpl(
        fluencyScore: null == fluencyScore
            ? _value.fluencyScore
            : fluencyScore // ignore: cast_nullable_to_non_nullable
                  as int,
        grammarScore: null == grammarScore
            ? _value.grammarScore
            : grammarScore // ignore: cast_nullable_to_non_nullable
                  as int,
        vocabularyScore: null == vocabularyScore
            ? _value.vocabularyScore
            : vocabularyScore // ignore: cast_nullable_to_non_nullable
                  as int,
        pronunciationScore: null == pronunciationScore
            ? _value.pronunciationScore
            : pronunciationScore // ignore: cast_nullable_to_non_nullable
                  as int,
        overallScore: null == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as int,
        feedback: null == feedback
            ? _value.feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as String,
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        issues: null == issues
            ? _value._issues
            : issues // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        practiceWords: null == practiceWords
            ? _value._practiceWords
            : practiceWords // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        shadowingExercise: null == shadowingExercise
            ? _value.shadowingExercise
            : shadowingExercise // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedProficiency: null == estimatedProficiency
            ? _value.estimatedProficiency
            : estimatedProficiency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PronunciationScoreImpl implements _PronunciationScore {
  const _$PronunciationScoreImpl({
    this.fluencyScore = 0,
    this.grammarScore = 0,
    this.vocabularyScore = 0,
    this.pronunciationScore = 0,
    this.overallScore = 0,
    this.feedback = '',
    final List<String> strengths = const [],
    final List<String> issues = const [],
    final List<String> practiceWords = const [],
    this.shadowingExercise = '',
    this.estimatedProficiency = '',
  }) : _strengths = strengths,
       _issues = issues,
       _practiceWords = practiceWords;

  factory _$PronunciationScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$PronunciationScoreImplFromJson(json);

  @override
  @JsonKey()
  final int fluencyScore;
  @override
  @JsonKey()
  final int grammarScore;
  @override
  @JsonKey()
  final int vocabularyScore;
  @override
  @JsonKey()
  final int pronunciationScore;
  @override
  @JsonKey()
  final int overallScore;
  @override
  @JsonKey()
  final String feedback;
  final List<String> _strengths;
  @override
  @JsonKey()
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _issues;
  @override
  @JsonKey()
  List<String> get issues {
    if (_issues is EqualUnmodifiableListView) return _issues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_issues);
  }

  final List<String> _practiceWords;
  @override
  @JsonKey()
  List<String> get practiceWords {
    if (_practiceWords is EqualUnmodifiableListView) return _practiceWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_practiceWords);
  }

  @override
  @JsonKey()
  final String shadowingExercise;
  @override
  @JsonKey()
  final String estimatedProficiency;

  @override
  String toString() {
    return 'PronunciationScore(fluencyScore: $fluencyScore, grammarScore: $grammarScore, vocabularyScore: $vocabularyScore, pronunciationScore: $pronunciationScore, overallScore: $overallScore, feedback: $feedback, strengths: $strengths, issues: $issues, practiceWords: $practiceWords, shadowingExercise: $shadowingExercise, estimatedProficiency: $estimatedProficiency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PronunciationScoreImpl &&
            (identical(other.fluencyScore, fluencyScore) ||
                other.fluencyScore == fluencyScore) &&
            (identical(other.grammarScore, grammarScore) ||
                other.grammarScore == grammarScore) &&
            (identical(other.vocabularyScore, vocabularyScore) ||
                other.vocabularyScore == vocabularyScore) &&
            (identical(other.pronunciationScore, pronunciationScore) ||
                other.pronunciationScore == pronunciationScore) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(other._issues, _issues) &&
            const DeepCollectionEquality().equals(
              other._practiceWords,
              _practiceWords,
            ) &&
            (identical(other.shadowingExercise, shadowingExercise) ||
                other.shadowingExercise == shadowingExercise) &&
            (identical(other.estimatedProficiency, estimatedProficiency) ||
                other.estimatedProficiency == estimatedProficiency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    fluencyScore,
    grammarScore,
    vocabularyScore,
    pronunciationScore,
    overallScore,
    feedback,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_issues),
    const DeepCollectionEquality().hash(_practiceWords),
    shadowingExercise,
    estimatedProficiency,
  );

  /// Create a copy of PronunciationScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PronunciationScoreImplCopyWith<_$PronunciationScoreImpl> get copyWith =>
      __$$PronunciationScoreImplCopyWithImpl<_$PronunciationScoreImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PronunciationScoreImplToJson(this);
  }
}

abstract class _PronunciationScore implements PronunciationScore {
  const factory _PronunciationScore({
    final int fluencyScore,
    final int grammarScore,
    final int vocabularyScore,
    final int pronunciationScore,
    final int overallScore,
    final String feedback,
    final List<String> strengths,
    final List<String> issues,
    final List<String> practiceWords,
    final String shadowingExercise,
    final String estimatedProficiency,
  }) = _$PronunciationScoreImpl;

  factory _PronunciationScore.fromJson(Map<String, dynamic> json) =
      _$PronunciationScoreImpl.fromJson;

  @override
  int get fluencyScore;
  @override
  int get grammarScore;
  @override
  int get vocabularyScore;
  @override
  int get pronunciationScore;
  @override
  int get overallScore;
  @override
  String get feedback;
  @override
  List<String> get strengths;
  @override
  List<String> get issues;
  @override
  List<String> get practiceWords;
  @override
  String get shadowingExercise;
  @override
  String get estimatedProficiency;

  /// Create a copy of PronunciationScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PronunciationScoreImplCopyWith<_$PronunciationScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
