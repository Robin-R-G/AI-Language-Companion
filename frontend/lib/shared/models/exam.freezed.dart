// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MockExam _$MockExamFromJson(Map<String, dynamic> json) {
  return _MockExam.fromJson(json);
}

/// @nodoc
mixin _$MockExam {
  String get id => throw _privateConstructorUsedError;
  String get examType => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this MockExam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamCopyWith<MockExam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamCopyWith<$Res> {
  factory $MockExamCopyWith(MockExam value, $Res Function(MockExam) then) =
      _$MockExamCopyWithImpl<$Res, MockExam>;
  @useResult
  $Res call({
    String id,
    String examType,
    String section,
    int duration,
    String? title,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$MockExamCopyWithImpl<$Res, $Val extends MockExam>
    implements $MockExamCopyWith<$Res> {
  _$MockExamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examType = null,
    Object? section = null,
    Object? duration = null,
    Object? title = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            examType: null == examType
                ? _value.examType
                : examType // ignore: cast_nullable_to_non_nullable
                      as String,
            section: null == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamImplCopyWith<$Res>
    implements $MockExamCopyWith<$Res> {
  factory _$$MockExamImplCopyWith(
    _$MockExamImpl value,
    $Res Function(_$MockExamImpl) then,
  ) = __$$MockExamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String examType,
    String section,
    int duration,
    String? title,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$MockExamImplCopyWithImpl<$Res>
    extends _$MockExamCopyWithImpl<$Res, _$MockExamImpl>
    implements _$$MockExamImplCopyWith<$Res> {
  __$$MockExamImplCopyWithImpl(
    _$MockExamImpl _value,
    $Res Function(_$MockExamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examType = null,
    Object? section = null,
    Object? duration = null,
    Object? title = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$MockExamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        examType: null == examType
            ? _value.examType
            : examType // ignore: cast_nullable_to_non_nullable
                  as String,
        section: null == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamImpl implements _MockExam {
  const _$MockExamImpl({
    required this.id,
    required this.examType,
    required this.section,
    required this.duration,
    this.title,
    this.startedAt,
    this.completedAt,
  });

  factory _$MockExamImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamImplFromJson(json);

  @override
  final String id;
  @override
  final String examType;
  @override
  final String section;
  @override
  final int duration;
  @override
  final String? title;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'MockExam(id: $id, examType: $examType, section: $section, duration: $duration, title: $title, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examType, examType) ||
                other.examType == examType) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examType,
    section,
    duration,
    title,
    startedAt,
    completedAt,
  );

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamImplCopyWith<_$MockExamImpl> get copyWith =>
      __$$MockExamImplCopyWithImpl<_$MockExamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamImplToJson(this);
  }
}

abstract class _MockExam implements MockExam {
  const factory _MockExam({
    required final String id,
    required final String examType,
    required final String section,
    required final int duration,
    final String? title,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) = _$MockExamImpl;

  factory _MockExam.fromJson(Map<String, dynamic> json) =
      _$MockExamImpl.fromJson;

  @override
  String get id;
  @override
  String get examType;
  @override
  String get section;
  @override
  int get duration;
  @override
  String? get title;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamImplCopyWith<_$MockExamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamResult _$ExamResultFromJson(Map<String, dynamic> json) {
  return _ExamResult.fromJson(json);
}

/// @nodoc
mixin _$ExamResult {
  String get id => throw _privateConstructorUsedError;
  String get examId => throw _privateConstructorUsedError;
  String get estimatedScore => throw _privateConstructorUsedError;
  int? get grammarScore => throw _privateConstructorUsedError;
  int? get vocabularyScore => throw _privateConstructorUsedError;
  int? get fluencyScore => throw _privateConstructorUsedError;
  String? get recommendations => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ExamResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamResultCopyWith<ExamResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamResultCopyWith<$Res> {
  factory $ExamResultCopyWith(
    ExamResult value,
    $Res Function(ExamResult) then,
  ) = _$ExamResultCopyWithImpl<$Res, ExamResult>;
  @useResult
  $Res call({
    String id,
    String examId,
    String estimatedScore,
    int? grammarScore,
    int? vocabularyScore,
    int? fluencyScore,
    String? recommendations,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ExamResultCopyWithImpl<$Res, $Val extends ExamResult>
    implements $ExamResultCopyWith<$Res> {
  _$ExamResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? estimatedScore = null,
    Object? grammarScore = freezed,
    Object? vocabularyScore = freezed,
    Object? fluencyScore = freezed,
    Object? recommendations = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            examId: null == examId
                ? _value.examId
                : examId // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedScore: null == estimatedScore
                ? _value.estimatedScore
                : estimatedScore // ignore: cast_nullable_to_non_nullable
                      as String,
            grammarScore: freezed == grammarScore
                ? _value.grammarScore
                : grammarScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            vocabularyScore: freezed == vocabularyScore
                ? _value.vocabularyScore
                : vocabularyScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            fluencyScore: freezed == fluencyScore
                ? _value.fluencyScore
                : fluencyScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            recommendations: freezed == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamResultImplCopyWith<$Res>
    implements $ExamResultCopyWith<$Res> {
  factory _$$ExamResultImplCopyWith(
    _$ExamResultImpl value,
    $Res Function(_$ExamResultImpl) then,
  ) = __$$ExamResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String examId,
    String estimatedScore,
    int? grammarScore,
    int? vocabularyScore,
    int? fluencyScore,
    String? recommendations,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ExamResultImplCopyWithImpl<$Res>
    extends _$ExamResultCopyWithImpl<$Res, _$ExamResultImpl>
    implements _$$ExamResultImplCopyWith<$Res> {
  __$$ExamResultImplCopyWithImpl(
    _$ExamResultImpl _value,
    $Res Function(_$ExamResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? estimatedScore = null,
    Object? grammarScore = freezed,
    Object? vocabularyScore = freezed,
    Object? fluencyScore = freezed,
    Object? recommendations = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ExamResultImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        examId: null == examId
            ? _value.examId
            : examId // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedScore: null == estimatedScore
            ? _value.estimatedScore
            : estimatedScore // ignore: cast_nullable_to_non_nullable
                  as String,
        grammarScore: freezed == grammarScore
            ? _value.grammarScore
            : grammarScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        vocabularyScore: freezed == vocabularyScore
            ? _value.vocabularyScore
            : vocabularyScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        fluencyScore: freezed == fluencyScore
            ? _value.fluencyScore
            : fluencyScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        recommendations: freezed == recommendations
            ? _value.recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamResultImpl implements _ExamResult {
  const _$ExamResultImpl({
    required this.id,
    required this.examId,
    required this.estimatedScore,
    this.grammarScore,
    this.vocabularyScore,
    this.fluencyScore,
    this.recommendations,
    this.createdAt,
  });

  factory _$ExamResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamResultImplFromJson(json);

  @override
  final String id;
  @override
  final String examId;
  @override
  final String estimatedScore;
  @override
  final int? grammarScore;
  @override
  final int? vocabularyScore;
  @override
  final int? fluencyScore;
  @override
  final String? recommendations;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ExamResult(id: $id, examId: $examId, estimatedScore: $estimatedScore, grammarScore: $grammarScore, vocabularyScore: $vocabularyScore, fluencyScore: $fluencyScore, recommendations: $recommendations, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examId, examId) || other.examId == examId) &&
            (identical(other.estimatedScore, estimatedScore) ||
                other.estimatedScore == estimatedScore) &&
            (identical(other.grammarScore, grammarScore) ||
                other.grammarScore == grammarScore) &&
            (identical(other.vocabularyScore, vocabularyScore) ||
                other.vocabularyScore == vocabularyScore) &&
            (identical(other.fluencyScore, fluencyScore) ||
                other.fluencyScore == fluencyScore) &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examId,
    estimatedScore,
    grammarScore,
    vocabularyScore,
    fluencyScore,
    recommendations,
    createdAt,
  );

  /// Create a copy of ExamResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamResultImplCopyWith<_$ExamResultImpl> get copyWith =>
      __$$ExamResultImplCopyWithImpl<_$ExamResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamResultImplToJson(this);
  }
}

abstract class _ExamResult implements ExamResult {
  const factory _ExamResult({
    required final String id,
    required final String examId,
    required final String estimatedScore,
    final int? grammarScore,
    final int? vocabularyScore,
    final int? fluencyScore,
    final String? recommendations,
    final DateTime? createdAt,
  }) = _$ExamResultImpl;

  factory _ExamResult.fromJson(Map<String, dynamic> json) =
      _$ExamResultImpl.fromJson;

  @override
  String get id;
  @override
  String get examId;
  @override
  String get estimatedScore;
  @override
  int? get grammarScore;
  @override
  int? get vocabularyScore;
  @override
  int? get fluencyScore;
  @override
  String? get recommendations;
  @override
  DateTime? get createdAt;

  /// Create a copy of ExamResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamResultImplCopyWith<_$ExamResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoiceSession _$VoiceSessionFromJson(Map<String, dynamic> json) {
  return _VoiceSession.fromJson(json);
}

/// @nodoc
mixin _$VoiceSession {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;

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
    int duration,
    String roomId,
    DateTime? startedAt,
    DateTime? endedAt,
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
    Object? duration = null,
    Object? roomId = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
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
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
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
    int duration,
    String roomId,
    DateTime? startedAt,
    DateTime? endedAt,
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
    Object? duration = null,
    Object? roomId = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
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
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
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
    required this.provider,
    required this.duration,
    required this.roomId,
    this.startedAt,
    this.endedAt,
  });

  factory _$VoiceSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String provider;
  @override
  final int duration;
  @override
  final String roomId;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;

  @override
  String toString() {
    return 'VoiceSession(id: $id, userId: $userId, provider: $provider, duration: $duration, roomId: $roomId, startedAt: $startedAt, endedAt: $endedAt)';
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
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    provider,
    duration,
    roomId,
    startedAt,
    endedAt,
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
    required final String provider,
    required final int duration,
    required final String roomId,
    final DateTime? startedAt,
    final DateTime? endedAt,
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
  int get duration;
  @override
  String get roomId;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;

  /// Create a copy of VoiceSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceSessionImplCopyWith<_$VoiceSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoiceTranscript _$VoiceTranscriptFromJson(Map<String, dynamic> json) {
  return _VoiceTranscript.fromJson(json);
}

/// @nodoc
mixin _$VoiceTranscript {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get transcript => throw _privateConstructorUsedError;
  String get aiResponse => throw _privateConstructorUsedError;
  int? get pronunciationScore => throw _privateConstructorUsedError;
  int? get fluencyScore => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this VoiceTranscript to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceTranscript
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceTranscriptCopyWith<VoiceTranscript> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceTranscriptCopyWith<$Res> {
  factory $VoiceTranscriptCopyWith(
    VoiceTranscript value,
    $Res Function(VoiceTranscript) then,
  ) = _$VoiceTranscriptCopyWithImpl<$Res, VoiceTranscript>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    String transcript,
    String aiResponse,
    int? pronunciationScore,
    int? fluencyScore,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$VoiceTranscriptCopyWithImpl<$Res, $Val extends VoiceTranscript>
    implements $VoiceTranscriptCopyWith<$Res> {
  _$VoiceTranscriptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceTranscript
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? transcript = null,
    Object? aiResponse = null,
    Object? pronunciationScore = freezed,
    Object? fluencyScore = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            transcript: null == transcript
                ? _value.transcript
                : transcript // ignore: cast_nullable_to_non_nullable
                      as String,
            aiResponse: null == aiResponse
                ? _value.aiResponse
                : aiResponse // ignore: cast_nullable_to_non_nullable
                      as String,
            pronunciationScore: freezed == pronunciationScore
                ? _value.pronunciationScore
                : pronunciationScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            fluencyScore: freezed == fluencyScore
                ? _value.fluencyScore
                : fluencyScore // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoiceTranscriptImplCopyWith<$Res>
    implements $VoiceTranscriptCopyWith<$Res> {
  factory _$$VoiceTranscriptImplCopyWith(
    _$VoiceTranscriptImpl value,
    $Res Function(_$VoiceTranscriptImpl) then,
  ) = __$$VoiceTranscriptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    String transcript,
    String aiResponse,
    int? pronunciationScore,
    int? fluencyScore,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$VoiceTranscriptImplCopyWithImpl<$Res>
    extends _$VoiceTranscriptCopyWithImpl<$Res, _$VoiceTranscriptImpl>
    implements _$$VoiceTranscriptImplCopyWith<$Res> {
  __$$VoiceTranscriptImplCopyWithImpl(
    _$VoiceTranscriptImpl _value,
    $Res Function(_$VoiceTranscriptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoiceTranscript
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? transcript = null,
    Object? aiResponse = null,
    Object? pronunciationScore = freezed,
    Object? fluencyScore = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$VoiceTranscriptImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        transcript: null == transcript
            ? _value.transcript
            : transcript // ignore: cast_nullable_to_non_nullable
                  as String,
        aiResponse: null == aiResponse
            ? _value.aiResponse
            : aiResponse // ignore: cast_nullable_to_non_nullable
                  as String,
        pronunciationScore: freezed == pronunciationScore
            ? _value.pronunciationScore
            : pronunciationScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        fluencyScore: freezed == fluencyScore
            ? _value.fluencyScore
            : fluencyScore // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceTranscriptImpl implements _VoiceTranscript {
  const _$VoiceTranscriptImpl({
    required this.id,
    required this.sessionId,
    required this.transcript,
    required this.aiResponse,
    this.pronunciationScore,
    this.fluencyScore,
    this.createdAt,
  });

  factory _$VoiceTranscriptImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceTranscriptImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final String transcript;
  @override
  final String aiResponse;
  @override
  final int? pronunciationScore;
  @override
  final int? fluencyScore;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'VoiceTranscript(id: $id, sessionId: $sessionId, transcript: $transcript, aiResponse: $aiResponse, pronunciationScore: $pronunciationScore, fluencyScore: $fluencyScore, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceTranscriptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.aiResponse, aiResponse) ||
                other.aiResponse == aiResponse) &&
            (identical(other.pronunciationScore, pronunciationScore) ||
                other.pronunciationScore == pronunciationScore) &&
            (identical(other.fluencyScore, fluencyScore) ||
                other.fluencyScore == fluencyScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    transcript,
    aiResponse,
    pronunciationScore,
    fluencyScore,
    createdAt,
  );

  /// Create a copy of VoiceTranscript
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceTranscriptImplCopyWith<_$VoiceTranscriptImpl> get copyWith =>
      __$$VoiceTranscriptImplCopyWithImpl<_$VoiceTranscriptImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceTranscriptImplToJson(this);
  }
}

abstract class _VoiceTranscript implements VoiceTranscript {
  const factory _VoiceTranscript({
    required final String id,
    required final String sessionId,
    required final String transcript,
    required final String aiResponse,
    final int? pronunciationScore,
    final int? fluencyScore,
    final DateTime? createdAt,
  }) = _$VoiceTranscriptImpl;

  factory _VoiceTranscript.fromJson(Map<String, dynamic> json) =
      _$VoiceTranscriptImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  String get transcript;
  @override
  String get aiResponse;
  @override
  int? get pronunciationScore;
  @override
  int? get fluencyScore;
  @override
  DateTime? get createdAt;

  /// Create a copy of VoiceTranscript
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceTranscriptImplCopyWith<_$VoiceTranscriptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
