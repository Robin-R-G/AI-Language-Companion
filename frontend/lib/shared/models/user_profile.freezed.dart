// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get authUserId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get nativeLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String get proficiencyLevel => throw _privateConstructorUsedError;
  String get targetExam => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  bool get onboardingCompleted => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String id,
    String authUserId,
    String fullName,
    String? avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String proficiencyLevel,
    String targetExam,
    String timezone,
    bool onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authUserId = null,
    Object? fullName = null,
    Object? avatarUrl = freezed,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = null,
    Object? targetExam = null,
    Object? timezone = null,
    Object? onboardingCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authUserId: null == authUserId
                ? _value.authUserId
                : authUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            nativeLanguage: null == nativeLanguage
                ? _value.nativeLanguage
                : nativeLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            targetLanguage: null == targetLanguage
                ? _value.targetLanguage
                : targetLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            proficiencyLevel: null == proficiencyLevel
                ? _value.proficiencyLevel
                : proficiencyLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            targetExam: null == targetExam
                ? _value.targetExam
                : targetExam // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: null == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String,
            onboardingCompleted: null == onboardingCompleted
                ? _value.onboardingCompleted
                : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authUserId,
    String fullName,
    String? avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String proficiencyLevel,
    String targetExam,
    String timezone,
    bool onboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authUserId = null,
    Object? fullName = null,
    Object? avatarUrl = freezed,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = null,
    Object? targetExam = null,
    Object? timezone = null,
    Object? onboardingCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authUserId: null == authUserId
            ? _value.authUserId
            : authUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        nativeLanguage: null == nativeLanguage
            ? _value.nativeLanguage
            : nativeLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        targetLanguage: null == targetLanguage
            ? _value.targetLanguage
            : targetLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        proficiencyLevel: null == proficiencyLevel
            ? _value.proficiencyLevel
            : proficiencyLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        targetExam: null == targetExam
            ? _value.targetExam
            : targetExam // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: null == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String,
        onboardingCompleted: null == onboardingCompleted
            ? _value.onboardingCompleted
            : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
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
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.id,
    required this.authUserId,
    required this.fullName,
    this.avatarUrl,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.proficiencyLevel,
    required this.targetExam,
    this.timezone = 'UTC',
    this.onboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String authUserId;
  @override
  final String fullName;
  @override
  final String? avatarUrl;
  @override
  final String nativeLanguage;
  @override
  final String targetLanguage;
  @override
  final String proficiencyLevel;
  @override
  final String targetExam;
  @override
  @JsonKey()
  final String timezone;
  @override
  @JsonKey()
  final bool onboardingCompleted;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfile(id: $id, authUserId: $authUserId, fullName: $fullName, avatarUrl: $avatarUrl, nativeLanguage: $nativeLanguage, targetLanguage: $targetLanguage, proficiencyLevel: $proficiencyLevel, targetExam: $targetExam, timezone: $timezone, onboardingCompleted: $onboardingCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authUserId, authUserId) ||
                other.authUserId == authUserId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.nativeLanguage, nativeLanguage) ||
                other.nativeLanguage == nativeLanguage) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.proficiencyLevel, proficiencyLevel) ||
                other.proficiencyLevel == proficiencyLevel) &&
            (identical(other.targetExam, targetExam) ||
                other.targetExam == targetExam) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
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
    authUserId,
    fullName,
    avatarUrl,
    nativeLanguage,
    targetLanguage,
    proficiencyLevel,
    targetExam,
    timezone,
    onboardingCompleted,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String id,
    required final String authUserId,
    required final String fullName,
    final String? avatarUrl,
    required final String nativeLanguage,
    required final String targetLanguage,
    required final String proficiencyLevel,
    required final String targetExam,
    final String timezone,
    final bool onboardingCompleted,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get authUserId;
  @override
  String get fullName;
  @override
  String? get avatarUrl;
  @override
  String get nativeLanguage;
  @override
  String get targetLanguage;
  @override
  String get proficiencyLevel;
  @override
  String get targetExam;
  @override
  String get timezone;
  @override
  bool get onboardingCompleted;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserGoals _$UserGoalsFromJson(Map<String, dynamic> json) {
  return _UserGoals.fromJson(json);
}

/// @nodoc
mixin _$UserGoals {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get dailyGoal => throw _privateConstructorUsedError;
  int get weeklyGoal => throw _privateConstructorUsedError;
  String? get targetExamScore => throw _privateConstructorUsedError;
  String? get reminderTime => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserGoals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserGoals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserGoalsCopyWith<UserGoals> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserGoalsCopyWith<$Res> {
  factory $UserGoalsCopyWith(UserGoals value, $Res Function(UserGoals) then) =
      _$UserGoalsCopyWithImpl<$Res, UserGoals>;
  @useResult
  $Res call({
    String id,
    String userId,
    int dailyGoal,
    int weeklyGoal,
    String? targetExamScore,
    String? reminderTime,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$UserGoalsCopyWithImpl<$Res, $Val extends UserGoals>
    implements $UserGoalsCopyWith<$Res> {
  _$UserGoalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserGoals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? dailyGoal = null,
    Object? weeklyGoal = null,
    Object? targetExamScore = freezed,
    Object? reminderTime = freezed,
    Object? createdAt = freezed,
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
            dailyGoal: null == dailyGoal
                ? _value.dailyGoal
                : dailyGoal // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyGoal: null == weeklyGoal
                ? _value.weeklyGoal
                : weeklyGoal // ignore: cast_nullable_to_non_nullable
                      as int,
            targetExamScore: freezed == targetExamScore
                ? _value.targetExamScore
                : targetExamScore // ignore: cast_nullable_to_non_nullable
                      as String?,
            reminderTime: freezed == reminderTime
                ? _value.reminderTime
                : reminderTime // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UserGoalsImplCopyWith<$Res>
    implements $UserGoalsCopyWith<$Res> {
  factory _$$UserGoalsImplCopyWith(
    _$UserGoalsImpl value,
    $Res Function(_$UserGoalsImpl) then,
  ) = __$$UserGoalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    int dailyGoal,
    int weeklyGoal,
    String? targetExamScore,
    String? reminderTime,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$UserGoalsImplCopyWithImpl<$Res>
    extends _$UserGoalsCopyWithImpl<$Res, _$UserGoalsImpl>
    implements _$$UserGoalsImplCopyWith<$Res> {
  __$$UserGoalsImplCopyWithImpl(
    _$UserGoalsImpl _value,
    $Res Function(_$UserGoalsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserGoals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? dailyGoal = null,
    Object? weeklyGoal = null,
    Object? targetExamScore = freezed,
    Object? reminderTime = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$UserGoalsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        dailyGoal: null == dailyGoal
            ? _value.dailyGoal
            : dailyGoal // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyGoal: null == weeklyGoal
            ? _value.weeklyGoal
            : weeklyGoal // ignore: cast_nullable_to_non_nullable
                  as int,
        targetExamScore: freezed == targetExamScore
            ? _value.targetExamScore
            : targetExamScore // ignore: cast_nullable_to_non_nullable
                  as String?,
        reminderTime: freezed == reminderTime
            ? _value.reminderTime
            : reminderTime // ignore: cast_nullable_to_non_nullable
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
class _$UserGoalsImpl implements _UserGoals {
  const _$UserGoalsImpl({
    required this.id,
    required this.userId,
    this.dailyGoal = 20,
    this.weeklyGoal = 140,
    this.targetExamScore,
    this.reminderTime,
    this.createdAt,
  });

  factory _$UserGoalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserGoalsImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final int dailyGoal;
  @override
  @JsonKey()
  final int weeklyGoal;
  @override
  final String? targetExamScore;
  @override
  final String? reminderTime;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserGoals(id: $id, userId: $userId, dailyGoal: $dailyGoal, weeklyGoal: $weeklyGoal, targetExamScore: $targetExamScore, reminderTime: $reminderTime, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserGoalsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.dailyGoal, dailyGoal) ||
                other.dailyGoal == dailyGoal) &&
            (identical(other.weeklyGoal, weeklyGoal) ||
                other.weeklyGoal == weeklyGoal) &&
            (identical(other.targetExamScore, targetExamScore) ||
                other.targetExamScore == targetExamScore) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    dailyGoal,
    weeklyGoal,
    targetExamScore,
    reminderTime,
    createdAt,
  );

  /// Create a copy of UserGoals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserGoalsImplCopyWith<_$UserGoalsImpl> get copyWith =>
      __$$UserGoalsImplCopyWithImpl<_$UserGoalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserGoalsImplToJson(this);
  }
}

abstract class _UserGoals implements UserGoals {
  const factory _UserGoals({
    required final String id,
    required final String userId,
    final int dailyGoal,
    final int weeklyGoal,
    final String? targetExamScore,
    final String? reminderTime,
    final DateTime? createdAt,
  }) = _$UserGoalsImpl;

  factory _UserGoals.fromJson(Map<String, dynamic> json) =
      _$UserGoalsImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get dailyGoal;
  @override
  int get weeklyGoal;
  @override
  String? get targetExamScore;
  @override
  String? get reminderTime;
  @override
  DateTime? get createdAt;

  /// Create a copy of UserGoals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserGoalsImplCopyWith<_$UserGoalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get grammarScore => throw _privateConstructorUsedError;
  int get speakingScore => throw _privateConstructorUsedError;
  int get writingScore => throw _privateConstructorUsedError;
  int get vocabularyScore => throw _privateConstructorUsedError;
  int get readingScore => throw _privateConstructorUsedError;
  int get listeningScore => throw _privateConstructorUsedError;
  DateTime? get lastStudyDate => throw _privateConstructorUsedError;

  /// Serializes this UserProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
    UserProgress value,
    $Res Function(UserProgress) then,
  ) = _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call({
    String id,
    String userId,
    int xp,
    int level,
    int grammarScore,
    int speakingScore,
    int writingScore,
    int vocabularyScore,
    int readingScore,
    int listeningScore,
    DateTime? lastStudyDate,
  });
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? xp = null,
    Object? level = null,
    Object? grammarScore = null,
    Object? speakingScore = null,
    Object? writingScore = null,
    Object? vocabularyScore = null,
    Object? readingScore = null,
    Object? listeningScore = null,
    Object? lastStudyDate = freezed,
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
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            grammarScore: null == grammarScore
                ? _value.grammarScore
                : grammarScore // ignore: cast_nullable_to_non_nullable
                      as int,
            speakingScore: null == speakingScore
                ? _value.speakingScore
                : speakingScore // ignore: cast_nullable_to_non_nullable
                      as int,
            writingScore: null == writingScore
                ? _value.writingScore
                : writingScore // ignore: cast_nullable_to_non_nullable
                      as int,
            vocabularyScore: null == vocabularyScore
                ? _value.vocabularyScore
                : vocabularyScore // ignore: cast_nullable_to_non_nullable
                      as int,
            readingScore: null == readingScore
                ? _value.readingScore
                : readingScore // ignore: cast_nullable_to_non_nullable
                      as int,
            listeningScore: null == listeningScore
                ? _value.listeningScore
                : listeningScore // ignore: cast_nullable_to_non_nullable
                      as int,
            lastStudyDate: freezed == lastStudyDate
                ? _value.lastStudyDate
                : lastStudyDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
    _$UserProgressImpl value,
    $Res Function(_$UserProgressImpl) then,
  ) = __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    int xp,
    int level,
    int grammarScore,
    int speakingScore,
    int writingScore,
    int vocabularyScore,
    int readingScore,
    int listeningScore,
    DateTime? lastStudyDate,
  });
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
    _$UserProgressImpl _value,
    $Res Function(_$UserProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? xp = null,
    Object? level = null,
    Object? grammarScore = null,
    Object? speakingScore = null,
    Object? writingScore = null,
    Object? vocabularyScore = null,
    Object? readingScore = null,
    Object? listeningScore = null,
    Object? lastStudyDate = freezed,
  }) {
    return _then(
      _$UserProgressImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        grammarScore: null == grammarScore
            ? _value.grammarScore
            : grammarScore // ignore: cast_nullable_to_non_nullable
                  as int,
        speakingScore: null == speakingScore
            ? _value.speakingScore
            : speakingScore // ignore: cast_nullable_to_non_nullable
                  as int,
        writingScore: null == writingScore
            ? _value.writingScore
            : writingScore // ignore: cast_nullable_to_non_nullable
                  as int,
        vocabularyScore: null == vocabularyScore
            ? _value.vocabularyScore
            : vocabularyScore // ignore: cast_nullable_to_non_nullable
                  as int,
        readingScore: null == readingScore
            ? _value.readingScore
            : readingScore // ignore: cast_nullable_to_non_nullable
                  as int,
        listeningScore: null == listeningScore
            ? _value.listeningScore
            : listeningScore // ignore: cast_nullable_to_non_nullable
                  as int,
        lastStudyDate: freezed == lastStudyDate
            ? _value.lastStudyDate
            : lastStudyDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl({
    required this.id,
    required this.userId,
    this.xp = 0,
    this.level = 1,
    this.grammarScore = 0,
    this.speakingScore = 0,
    this.writingScore = 0,
    this.vocabularyScore = 0,
    this.readingScore = 0,
    this.listeningScore = 0,
    this.lastStudyDate,
  });

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final int xp;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int grammarScore;
  @override
  @JsonKey()
  final int speakingScore;
  @override
  @JsonKey()
  final int writingScore;
  @override
  @JsonKey()
  final int vocabularyScore;
  @override
  @JsonKey()
  final int readingScore;
  @override
  @JsonKey()
  final int listeningScore;
  @override
  final DateTime? lastStudyDate;

  @override
  String toString() {
    return 'UserProgress(id: $id, userId: $userId, xp: $xp, level: $level, grammarScore: $grammarScore, speakingScore: $speakingScore, writingScore: $writingScore, vocabularyScore: $vocabularyScore, readingScore: $readingScore, listeningScore: $listeningScore, lastStudyDate: $lastStudyDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.grammarScore, grammarScore) ||
                other.grammarScore == grammarScore) &&
            (identical(other.speakingScore, speakingScore) ||
                other.speakingScore == speakingScore) &&
            (identical(other.writingScore, writingScore) ||
                other.writingScore == writingScore) &&
            (identical(other.vocabularyScore, vocabularyScore) ||
                other.vocabularyScore == vocabularyScore) &&
            (identical(other.readingScore, readingScore) ||
                other.readingScore == readingScore) &&
            (identical(other.listeningScore, listeningScore) ||
                other.listeningScore == listeningScore) &&
            (identical(other.lastStudyDate, lastStudyDate) ||
                other.lastStudyDate == lastStudyDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    xp,
    level,
    grammarScore,
    speakingScore,
    writingScore,
    vocabularyScore,
    readingScore,
    listeningScore,
    lastStudyDate,
  );

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(this);
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress({
    required final String id,
    required final String userId,
    final int xp,
    final int level,
    final int grammarScore,
    final int speakingScore,
    final int writingScore,
    final int vocabularyScore,
    final int readingScore,
    final int listeningScore,
    final DateTime? lastStudyDate,
  }) = _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get xp;
  @override
  int get level;
  @override
  int get grammarScore;
  @override
  int get speakingScore;
  @override
  int get writingScore;
  @override
  int get vocabularyScore;
  @override
  int get readingScore;
  @override
  int get listeningScore;
  @override
  DateTime? get lastStudyDate;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStreak _$UserStreakFromJson(Map<String, dynamic> json) {
  return _UserStreak.fromJson(json);
}

/// @nodoc
mixin _$UserStreak {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get freezeCount => throw _privateConstructorUsedError;
  DateTime? get lastActiveDate => throw _privateConstructorUsedError;

  /// Serializes this UserStreak to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStreak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStreakCopyWith<UserStreak> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStreakCopyWith<$Res> {
  factory $UserStreakCopyWith(
    UserStreak value,
    $Res Function(UserStreak) then,
  ) = _$UserStreakCopyWithImpl<$Res, UserStreak>;
  @useResult
  $Res call({
    String id,
    String userId,
    int currentStreak,
    int longestStreak,
    int freezeCount,
    DateTime? lastActiveDate,
  });
}

/// @nodoc
class _$UserStreakCopyWithImpl<$Res, $Val extends UserStreak>
    implements $UserStreakCopyWith<$Res> {
  _$UserStreakCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStreak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? freezeCount = null,
    Object? lastActiveDate = freezed,
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
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            freezeCount: null == freezeCount
                ? _value.freezeCount
                : freezeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastActiveDate: freezed == lastActiveDate
                ? _value.lastActiveDate
                : lastActiveDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserStreakImplCopyWith<$Res>
    implements $UserStreakCopyWith<$Res> {
  factory _$$UserStreakImplCopyWith(
    _$UserStreakImpl value,
    $Res Function(_$UserStreakImpl) then,
  ) = __$$UserStreakImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    int currentStreak,
    int longestStreak,
    int freezeCount,
    DateTime? lastActiveDate,
  });
}

/// @nodoc
class __$$UserStreakImplCopyWithImpl<$Res>
    extends _$UserStreakCopyWithImpl<$Res, _$UserStreakImpl>
    implements _$$UserStreakImplCopyWith<$Res> {
  __$$UserStreakImplCopyWithImpl(
    _$UserStreakImpl _value,
    $Res Function(_$UserStreakImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStreak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? freezeCount = null,
    Object? lastActiveDate = freezed,
  }) {
    return _then(
      _$UserStreakImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        freezeCount: null == freezeCount
            ? _value.freezeCount
            : freezeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastActiveDate: freezed == lastActiveDate
            ? _value.lastActiveDate
            : lastActiveDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStreakImpl implements _UserStreak {
  const _$UserStreakImpl({
    required this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.freezeCount = 0,
    this.lastActiveDate,
  });

  factory _$UserStreakImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStreakImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @JsonKey()
  final int freezeCount;
  @override
  final DateTime? lastActiveDate;

  @override
  String toString() {
    return 'UserStreak(id: $id, userId: $userId, currentStreak: $currentStreak, longestStreak: $longestStreak, freezeCount: $freezeCount, lastActiveDate: $lastActiveDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStreakImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.freezeCount, freezeCount) ||
                other.freezeCount == freezeCount) &&
            (identical(other.lastActiveDate, lastActiveDate) ||
                other.lastActiveDate == lastActiveDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    currentStreak,
    longestStreak,
    freezeCount,
    lastActiveDate,
  );

  /// Create a copy of UserStreak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStreakImplCopyWith<_$UserStreakImpl> get copyWith =>
      __$$UserStreakImplCopyWithImpl<_$UserStreakImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStreakImplToJson(this);
  }
}

abstract class _UserStreak implements UserStreak {
  const factory _UserStreak({
    required final String id,
    required final String userId,
    final int currentStreak,
    final int longestStreak,
    final int freezeCount,
    final DateTime? lastActiveDate,
  }) = _$UserStreakImpl;

  factory _UserStreak.fromJson(Map<String, dynamic> json) =
      _$UserStreakImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  int get freezeCount;
  @override
  DateTime? get lastActiveDate;

  /// Create a copy of UserStreak
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStreakImplCopyWith<_$UserStreakImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
