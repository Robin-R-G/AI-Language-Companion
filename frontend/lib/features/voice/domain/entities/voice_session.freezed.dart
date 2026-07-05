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
  String get sessionType => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get liveKitRoomName => throw _privateConstructorUsedError;
  String? get recordingUrl => throw _privateConstructorUsedError;
  String? get transcript => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

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
    String sessionType,
    String targetLanguage,
    String topic,
    int durationMinutes,
    int xpEarned,
    String status,
    String? liveKitRoomName,
    String? recordingUrl,
    String? transcript,
    DateTime startedAt,
    DateTime? endedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? sessionType = null,
    Object? targetLanguage = null,
    Object? topic = null,
    Object? durationMinutes = null,
    Object? xpEarned = null,
    Object? status = null,
    Object? liveKitRoomName = freezed,
    Object? recordingUrl = freezed,
    Object? transcript = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            sessionType: null == sessionType
                ? _value.sessionType
                : sessionType // ignore: cast_nullable_to_non_nullable
                      as String,
            targetLanguage: null == targetLanguage
                ? _value.targetLanguage
                : targetLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            topic: null == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            xpEarned: null == xpEarned
                ? _value.xpEarned
                : xpEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            liveKitRoomName: freezed == liveKitRoomName
                ? _value.liveKitRoomName
                : liveKitRoomName // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordingUrl: freezed == recordingUrl
                ? _value.recordingUrl
                : recordingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            transcript: freezed == transcript
                ? _value.transcript
                : transcript // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
    String sessionType,
    String targetLanguage,
    String topic,
    int durationMinutes,
    int xpEarned,
    String status,
    String? liveKitRoomName,
    String? recordingUrl,
    String? transcript,
    DateTime startedAt,
    DateTime? endedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? sessionType = null,
    Object? targetLanguage = null,
    Object? topic = null,
    Object? durationMinutes = null,
    Object? xpEarned = null,
    Object? status = null,
    Object? liveKitRoomName = freezed,
    Object? recordingUrl = freezed,
    Object? transcript = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
        sessionType: null == sessionType
            ? _value.sessionType
            : sessionType // ignore: cast_nullable_to_non_nullable
                  as String,
        targetLanguage: null == targetLanguage
            ? _value.targetLanguage
            : targetLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        xpEarned: null == xpEarned
            ? _value.xpEarned
            : xpEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        liveKitRoomName: freezed == liveKitRoomName
            ? _value.liveKitRoomName
            : liveKitRoomName // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordingUrl: freezed == recordingUrl
            ? _value.recordingUrl
            : recordingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        transcript: freezed == transcript
            ? _value.transcript
            : transcript // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
    required this.sessionType,
    required this.targetLanguage,
    required this.topic,
    required this.durationMinutes,
    required this.xpEarned,
    required this.status,
    this.liveKitRoomName,
    this.recordingUrl,
    this.transcript,
    required this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$VoiceSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String sessionType;
  @override
  final String targetLanguage;
  @override
  final String topic;
  @override
  final int durationMinutes;
  @override
  final int xpEarned;
  @override
  final String status;
  @override
  final String? liveKitRoomName;
  @override
  final String? recordingUrl;
  @override
  final String? transcript;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VoiceSession(id: $id, userId: $userId, sessionType: $sessionType, targetLanguage: $targetLanguage, topic: $topic, durationMinutes: $durationMinutes, xpEarned: $xpEarned, status: $status, liveKitRoomName: $liveKitRoomName, recordingUrl: $recordingUrl, transcript: $transcript, startedAt: $startedAt, endedAt: $endedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.liveKitRoomName, liveKitRoomName) ||
                other.liveKitRoomName == liveKitRoomName) &&
            (identical(other.recordingUrl, recordingUrl) ||
                other.recordingUrl == recordingUrl) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    sessionType,
    targetLanguage,
    topic,
    durationMinutes,
    xpEarned,
    status,
    liveKitRoomName,
    recordingUrl,
    transcript,
    startedAt,
    endedAt,
    createdAt,
    updatedAt,
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
    required final String sessionType,
    required final String targetLanguage,
    required final String topic,
    required final int durationMinutes,
    required final int xpEarned,
    required final String status,
    final String? liveKitRoomName,
    final String? recordingUrl,
    final String? transcript,
    required final DateTime startedAt,
    final DateTime? endedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VoiceSessionImpl;

  factory _VoiceSession.fromJson(Map<String, dynamic> json) =
      _$VoiceSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get sessionType;
  @override
  String get targetLanguage;
  @override
  String get topic;
  @override
  int get durationMinutes;
  @override
  int get xpEarned;
  @override
  String get status;
  @override
  String? get liveKitRoomName;
  @override
  String? get recordingUrl;
  @override
  String? get transcript;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

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
  String get sessionId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get overallScore => throw _privateConstructorUsedError;
  double get fluency => throw _privateConstructorUsedError;
  double get clarity => throw _privateConstructorUsedError;
  double get stress => throw _privateConstructorUsedError;
  double get intonation => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  List<WordScore> get wordScores => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

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
    String sessionId,
    String userId,
    double overallScore,
    double fluency,
    double clarity,
    double stress,
    double intonation,
    double confidence,
    List<WordScore> wordScores,
    DateTime createdAt,
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
    Object? sessionId = null,
    Object? userId = null,
    Object? overallScore = null,
    Object? fluency = null,
    Object? clarity = null,
    Object? stress = null,
    Object? intonation = null,
    Object? confidence = null,
    Object? wordScores = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            overallScore: null == overallScore
                ? _value.overallScore
                : overallScore // ignore: cast_nullable_to_non_nullable
                      as double,
            fluency: null == fluency
                ? _value.fluency
                : fluency // ignore: cast_nullable_to_non_nullable
                      as double,
            clarity: null == clarity
                ? _value.clarity
                : clarity // ignore: cast_nullable_to_non_nullable
                      as double,
            stress: null == stress
                ? _value.stress
                : stress // ignore: cast_nullable_to_non_nullable
                      as double,
            intonation: null == intonation
                ? _value.intonation
                : intonation // ignore: cast_nullable_to_non_nullable
                      as double,
            confidence: null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                      as double,
            wordScores: null == wordScores
                ? _value.wordScores
                : wordScores // ignore: cast_nullable_to_non_nullable
                      as List<WordScore>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
    String sessionId,
    String userId,
    double overallScore,
    double fluency,
    double clarity,
    double stress,
    double intonation,
    double confidence,
    List<WordScore> wordScores,
    DateTime createdAt,
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
    Object? sessionId = null,
    Object? userId = null,
    Object? overallScore = null,
    Object? fluency = null,
    Object? clarity = null,
    Object? stress = null,
    Object? intonation = null,
    Object? confidence = null,
    Object? wordScores = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PronunciationScoreImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        overallScore: null == overallScore
            ? _value.overallScore
            : overallScore // ignore: cast_nullable_to_non_nullable
                  as double,
        fluency: null == fluency
            ? _value.fluency
            : fluency // ignore: cast_nullable_to_non_nullable
                  as double,
        clarity: null == clarity
            ? _value.clarity
            : clarity // ignore: cast_nullable_to_non_nullable
                  as double,
        stress: null == stress
            ? _value.stress
            : stress // ignore: cast_nullable_to_non_nullable
                  as double,
        intonation: null == intonation
            ? _value.intonation
            : intonation // ignore: cast_nullable_to_non_nullable
                  as double,
        confidence: null == confidence
            ? _value.confidence
            : confidence // ignore: cast_nullable_to_non_nullable
                  as double,
        wordScores: null == wordScores
            ? _value._wordScores
            : wordScores // ignore: cast_nullable_to_non_nullable
                  as List<WordScore>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PronunciationScoreImpl implements _PronunciationScore {
  const _$PronunciationScoreImpl({
    required this.sessionId,
    required this.userId,
    required this.overallScore,
    required this.fluency,
    required this.clarity,
    required this.stress,
    required this.intonation,
    required this.confidence,
    required final List<WordScore> wordScores,
    required this.createdAt,
  }) : _wordScores = wordScores;

  factory _$PronunciationScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$PronunciationScoreImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String userId;
  @override
  final double overallScore;
  @override
  final double fluency;
  @override
  final double clarity;
  @override
  final double stress;
  @override
  final double intonation;
  @override
  final double confidence;
  final List<WordScore> _wordScores;
  @override
  List<WordScore> get wordScores {
    if (_wordScores is EqualUnmodifiableListView) return _wordScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wordScores);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PronunciationScore(sessionId: $sessionId, userId: $userId, overallScore: $overallScore, fluency: $fluency, clarity: $clarity, stress: $stress, intonation: $intonation, confidence: $confidence, wordScores: $wordScores, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PronunciationScoreImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.fluency, fluency) || other.fluency == fluency) &&
            (identical(other.clarity, clarity) || other.clarity == clarity) &&
            (identical(other.stress, stress) || other.stress == stress) &&
            (identical(other.intonation, intonation) ||
                other.intonation == intonation) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(
              other._wordScores,
              _wordScores,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    userId,
    overallScore,
    fluency,
    clarity,
    stress,
    intonation,
    confidence,
    const DeepCollectionEquality().hash(_wordScores),
    createdAt,
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
    required final String sessionId,
    required final String userId,
    required final double overallScore,
    required final double fluency,
    required final double clarity,
    required final double stress,
    required final double intonation,
    required final double confidence,
    required final List<WordScore> wordScores,
    required final DateTime createdAt,
  }) = _$PronunciationScoreImpl;

  factory _PronunciationScore.fromJson(Map<String, dynamic> json) =
      _$PronunciationScoreImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get userId;
  @override
  double get overallScore;
  @override
  double get fluency;
  @override
  double get clarity;
  @override
  double get stress;
  @override
  double get intonation;
  @override
  double get confidence;
  @override
  List<WordScore> get wordScores;
  @override
  DateTime get createdAt;

  /// Create a copy of PronunciationScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PronunciationScoreImplCopyWith<_$PronunciationScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WordScore _$WordScoreFromJson(Map<String, dynamic> json) {
  return _WordScore.fromJson(json);
}

/// @nodoc
mixin _$WordScore {
  String get word => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this WordScore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WordScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WordScoreCopyWith<WordScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WordScoreCopyWith<$Res> {
  factory $WordScoreCopyWith(WordScore value, $Res Function(WordScore) then) =
      _$WordScoreCopyWithImpl<$Res, WordScore>;
  @useResult
  $Res call({String word, double score, String status});
}

/// @nodoc
class _$WordScoreCopyWithImpl<$Res, $Val extends WordScore>
    implements $WordScoreCopyWith<$Res> {
  _$WordScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WordScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? score = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            word: null == word
                ? _value.word
                : word // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WordScoreImplCopyWith<$Res>
    implements $WordScoreCopyWith<$Res> {
  factory _$$WordScoreImplCopyWith(
    _$WordScoreImpl value,
    $Res Function(_$WordScoreImpl) then,
  ) = __$$WordScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String word, double score, String status});
}

/// @nodoc
class __$$WordScoreImplCopyWithImpl<$Res>
    extends _$WordScoreCopyWithImpl<$Res, _$WordScoreImpl>
    implements _$$WordScoreImplCopyWith<$Res> {
  __$$WordScoreImplCopyWithImpl(
    _$WordScoreImpl _value,
    $Res Function(_$WordScoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WordScore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? score = null,
    Object? status = null,
  }) {
    return _then(
      _$WordScoreImpl(
        word: null == word
            ? _value.word
            : word // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WordScoreImpl implements _WordScore {
  const _$WordScoreImpl({
    required this.word,
    required this.score,
    required this.status,
  });

  factory _$WordScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$WordScoreImplFromJson(json);

  @override
  final String word;
  @override
  final double score;
  @override
  final String status;

  @override
  String toString() {
    return 'WordScore(word: $word, score: $score, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WordScoreImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, word, score, status);

  /// Create a copy of WordScore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WordScoreImplCopyWith<_$WordScoreImpl> get copyWith =>
      __$$WordScoreImplCopyWithImpl<_$WordScoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WordScoreImplToJson(this);
  }
}

abstract class _WordScore implements WordScore {
  const factory _WordScore({
    required final String word,
    required final double score,
    required final String status,
  }) = _$WordScoreImpl;

  factory _WordScore.fromJson(Map<String, dynamic> json) =
      _$WordScoreImpl.fromJson;

  @override
  String get word;
  @override
  double get score;
  @override
  String get status;

  /// Create a copy of WordScore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WordScoreImplCopyWith<_$WordScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
