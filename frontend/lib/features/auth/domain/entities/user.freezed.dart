// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get nativeLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String? get proficiencyLevel => throw _privateConstructorUsedError;
  String? get targetExam => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  bool get onboardingCompleted => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  DateTime get lastActiveAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call({
    String id,
    String email,
    String? fullName,
    String? avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    bool onboardingCompleted,
    int xp,
    int level,
    int streak,
    int longestStreak,
    DateTime lastActiveAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = freezed,
    Object? targetExam = freezed,
    Object? timezone = freezed,
    Object? onboardingCompleted = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? longestStreak = null,
    Object? lastActiveAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            proficiencyLevel: freezed == proficiencyLevel
                ? _value.proficiencyLevel
                : proficiencyLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetExam: freezed == targetExam
                ? _value.targetExam
                : targetExam // ignore: cast_nullable_to_non_nullable
                      as String?,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
            onboardingCompleted: null == onboardingCompleted
                ? _value.onboardingCompleted
                : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            streak: null == streak
                ? _value.streak
                : streak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            lastActiveAt: null == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
    _$AppUserImpl value,
    $Res Function(_$AppUserImpl) then,
  ) = __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? fullName,
    String? avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    bool onboardingCompleted,
    int xp,
    int level,
    int streak,
    int longestStreak,
    DateTime lastActiveAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
    _$AppUserImpl _value,
    $Res Function(_$AppUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = freezed,
    Object? targetExam = freezed,
    Object? timezone = freezed,
    Object? onboardingCompleted = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? longestStreak = null,
    Object? lastActiveAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$AppUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        proficiencyLevel: freezed == proficiencyLevel
            ? _value.proficiencyLevel
            : proficiencyLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetExam: freezed == targetExam
            ? _value.targetExam
            : targetExam // ignore: cast_nullable_to_non_nullable
                  as String?,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        onboardingCompleted: null == onboardingCompleted
            ? _value.onboardingCompleted
            : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        streak: null == streak
            ? _value.streak
            : streak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        lastActiveAt: null == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.nativeLanguage,
    required this.targetLanguage,
    this.proficiencyLevel,
    this.targetExam,
    this.timezone,
    required this.onboardingCompleted,
    required this.xp,
    required this.level,
    required this.streak,
    required this.longestStreak,
    required this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? fullName;
  @override
  final String? avatarUrl;
  @override
  final String nativeLanguage;
  @override
  final String targetLanguage;
  @override
  final String? proficiencyLevel;
  @override
  final String? targetExam;
  @override
  final String? timezone;
  @override
  final bool onboardingCompleted;
  @override
  final int xp;
  @override
  final int level;
  @override
  final int streak;
  @override
  final int longestStreak;
  @override
  final DateTime lastActiveAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, nativeLanguage: $nativeLanguage, targetLanguage: $targetLanguage, proficiencyLevel: $proficiencyLevel, targetExam: $targetExam, timezone: $timezone, onboardingCompleted: $onboardingCompleted, xp: $xp, level: $level, streak: $streak, longestStreak: $longestStreak, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
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
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
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
    email,
    fullName,
    avatarUrl,
    nativeLanguage,
    targetLanguage,
    proficiencyLevel,
    targetExam,
    timezone,
    onboardingCompleted,
    xp,
    level,
    streak,
    longestStreak,
    lastActiveAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(this);
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser({
    required final String id,
    required final String email,
    final String? fullName,
    final String? avatarUrl,
    required final String nativeLanguage,
    required final String targetLanguage,
    final String? proficiencyLevel,
    final String? targetExam,
    final String? timezone,
    required final bool onboardingCompleted,
    required final int xp,
    required final int level,
    required final int streak,
    required final int longestStreak,
    required final DateTime lastActiveAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get fullName;
  @override
  String? get avatarUrl;
  @override
  String get nativeLanguage;
  @override
  String get targetLanguage;
  @override
  String? get proficiencyLevel;
  @override
  String? get targetExam;
  @override
  String? get timezone;
  @override
  bool get onboardingCompleted;
  @override
  int get xp;
  @override
  int get level;
  @override
  int get streak;
  @override
  int get longestStreak;
  @override
  DateTime get lastActiveAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get userId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get nativeLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String? get proficiencyLevel => throw _privateConstructorUsedError;
  String? get targetExam => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  bool get onboardingCompleted => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get dailyGoalMinutes => throw _privateConstructorUsedError;
  DateTime? get lastStudyDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

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
    String userId,
    String email,
    String? fullName,
    String? avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    bool onboardingCompleted,
    int xp,
    int level,
    int streak,
    int longestStreak,
    int dailyGoalMinutes,
    DateTime? lastStudyDate,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? userId = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = freezed,
    Object? targetExam = freezed,
    Object? timezone = freezed,
    Object? onboardingCompleted = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? longestStreak = null,
    Object? dailyGoalMinutes = null,
    Object? lastStudyDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            proficiencyLevel: freezed == proficiencyLevel
                ? _value.proficiencyLevel
                : proficiencyLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetExam: freezed == targetExam
                ? _value.targetExam
                : targetExam // ignore: cast_nullable_to_non_nullable
                      as String?,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
            onboardingCompleted: null == onboardingCompleted
                ? _value.onboardingCompleted
                : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            streak: null == streak
                ? _value.streak
                : streak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyGoalMinutes: null == dailyGoalMinutes
                ? _value.dailyGoalMinutes
                : dailyGoalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            lastStudyDate: freezed == lastStudyDate
                ? _value.lastStudyDate
                : lastStudyDate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String email,
    String? fullName,
    String? avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String? proficiencyLevel,
    String? targetExam,
    String? timezone,
    bool onboardingCompleted,
    int xp,
    int level,
    int streak,
    int longestStreak,
    int dailyGoalMinutes,
    DateTime? lastStudyDate,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? userId = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? avatarUrl = freezed,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = freezed,
    Object? targetExam = freezed,
    Object? timezone = freezed,
    Object? onboardingCompleted = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? longestStreak = null,
    Object? dailyGoalMinutes = null,
    Object? lastStudyDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$UserProfileImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        proficiencyLevel: freezed == proficiencyLevel
            ? _value.proficiencyLevel
            : proficiencyLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetExam: freezed == targetExam
            ? _value.targetExam
            : targetExam // ignore: cast_nullable_to_non_nullable
                  as String?,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
        onboardingCompleted: null == onboardingCompleted
            ? _value.onboardingCompleted
            : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        streak: null == streak
            ? _value.streak
            : streak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyGoalMinutes: null == dailyGoalMinutes
            ? _value.dailyGoalMinutes
            : dailyGoalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        lastStudyDate: freezed == lastStudyDate
            ? _value.lastStudyDate
            : lastStudyDate // ignore: cast_nullable_to_non_nullable
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
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.userId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.nativeLanguage,
    required this.targetLanguage,
    this.proficiencyLevel,
    this.targetExam,
    this.timezone,
    required this.onboardingCompleted,
    required this.xp,
    required this.level,
    required this.streak,
    required this.longestStreak,
    required this.dailyGoalMinutes,
    required this.lastStudyDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String userId;
  @override
  final String email;
  @override
  final String? fullName;
  @override
  final String? avatarUrl;
  @override
  final String nativeLanguage;
  @override
  final String targetLanguage;
  @override
  final String? proficiencyLevel;
  @override
  final String? targetExam;
  @override
  final String? timezone;
  @override
  final bool onboardingCompleted;
  @override
  final int xp;
  @override
  final int level;
  @override
  final int streak;
  @override
  final int longestStreak;
  @override
  final int dailyGoalMinutes;
  @override
  final DateTime? lastStudyDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: $email, fullName: $fullName, avatarUrl: $avatarUrl, nativeLanguage: $nativeLanguage, targetLanguage: $targetLanguage, proficiencyLevel: $proficiencyLevel, targetExam: $targetExam, timezone: $timezone, onboardingCompleted: $onboardingCompleted, xp: $xp, level: $level, streak: $streak, longestStreak: $longestStreak, dailyGoalMinutes: $dailyGoalMinutes, lastStudyDate: $lastStudyDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
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
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.dailyGoalMinutes, dailyGoalMinutes) ||
                other.dailyGoalMinutes == dailyGoalMinutes) &&
            (identical(other.lastStudyDate, lastStudyDate) ||
                other.lastStudyDate == lastStudyDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    email,
    fullName,
    avatarUrl,
    nativeLanguage,
    targetLanguage,
    proficiencyLevel,
    targetExam,
    timezone,
    onboardingCompleted,
    xp,
    level,
    streak,
    longestStreak,
    dailyGoalMinutes,
    lastStudyDate,
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
    required final String userId,
    required final String email,
    final String? fullName,
    final String? avatarUrl,
    required final String nativeLanguage,
    required final String targetLanguage,
    final String? proficiencyLevel,
    final String? targetExam,
    final String? timezone,
    required final bool onboardingCompleted,
    required final int xp,
    required final int level,
    required final int streak,
    required final int longestStreak,
    required final int dailyGoalMinutes,
    required final DateTime? lastStudyDate,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get userId;
  @override
  String get email;
  @override
  String? get fullName;
  @override
  String? get avatarUrl;
  @override
  String get nativeLanguage;
  @override
  String get targetLanguage;
  @override
  String? get proficiencyLevel;
  @override
  String? get targetExam;
  @override
  String? get timezone;
  @override
  bool get onboardingCompleted;
  @override
  int get xp;
  @override
  int get level;
  @override
  int get streak;
  @override
  int get longestStreak;
  @override
  int get dailyGoalMinutes;
  @override
  DateTime? get lastStudyDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OnboardingData _$OnboardingDataFromJson(Map<String, dynamic> json) {
  return _OnboardingData.fromJson(json);
}

/// @nodoc
mixin _$OnboardingData {
  String get nativeLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String get proficiencyLevel => throw _privateConstructorUsedError;
  String? get targetExam => throw _privateConstructorUsedError;
  int get dailyGoalMinutes => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;

  /// Serializes this OnboardingData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingDataCopyWith<OnboardingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingDataCopyWith<$Res> {
  factory $OnboardingDataCopyWith(
    OnboardingData value,
    $Res Function(OnboardingData) then,
  ) = _$OnboardingDataCopyWithImpl<$Res, OnboardingData>;
  @useResult
  $Res call({
    String nativeLanguage,
    String targetLanguage,
    String proficiencyLevel,
    String? targetExam,
    int dailyGoalMinutes,
    String? timezone,
  });
}

/// @nodoc
class _$OnboardingDataCopyWithImpl<$Res, $Val extends OnboardingData>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = null,
    Object? targetExam = freezed,
    Object? dailyGoalMinutes = null,
    Object? timezone = freezed,
  }) {
    return _then(
      _value.copyWith(
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
            targetExam: freezed == targetExam
                ? _value.targetExam
                : targetExam // ignore: cast_nullable_to_non_nullable
                      as String?,
            dailyGoalMinutes: null == dailyGoalMinutes
                ? _value.dailyGoalMinutes
                : dailyGoalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingDataImplCopyWith<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  factory _$$OnboardingDataImplCopyWith(
    _$OnboardingDataImpl value,
    $Res Function(_$OnboardingDataImpl) then,
  ) = __$$OnboardingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String nativeLanguage,
    String targetLanguage,
    String proficiencyLevel,
    String? targetExam,
    int dailyGoalMinutes,
    String? timezone,
  });
}

/// @nodoc
class __$$OnboardingDataImplCopyWithImpl<$Res>
    extends _$OnboardingDataCopyWithImpl<$Res, _$OnboardingDataImpl>
    implements _$$OnboardingDataImplCopyWith<$Res> {
  __$$OnboardingDataImplCopyWithImpl(
    _$OnboardingDataImpl _value,
    $Res Function(_$OnboardingDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = null,
    Object? targetExam = freezed,
    Object? dailyGoalMinutes = null,
    Object? timezone = freezed,
  }) {
    return _then(
      _$OnboardingDataImpl(
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
        targetExam: freezed == targetExam
            ? _value.targetExam
            : targetExam // ignore: cast_nullable_to_non_nullable
                  as String?,
        dailyGoalMinutes: null == dailyGoalMinutes
            ? _value.dailyGoalMinutes
            : dailyGoalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnboardingDataImpl implements _OnboardingData {
  const _$OnboardingDataImpl({
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.proficiencyLevel,
    this.targetExam,
    required this.dailyGoalMinutes,
    this.timezone,
  });

  factory _$OnboardingDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnboardingDataImplFromJson(json);

  @override
  final String nativeLanguage;
  @override
  final String targetLanguage;
  @override
  final String proficiencyLevel;
  @override
  final String? targetExam;
  @override
  final int dailyGoalMinutes;
  @override
  final String? timezone;

  @override
  String toString() {
    return 'OnboardingData(nativeLanguage: $nativeLanguage, targetLanguage: $targetLanguage, proficiencyLevel: $proficiencyLevel, targetExam: $targetExam, dailyGoalMinutes: $dailyGoalMinutes, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingDataImpl &&
            (identical(other.nativeLanguage, nativeLanguage) ||
                other.nativeLanguage == nativeLanguage) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.proficiencyLevel, proficiencyLevel) ||
                other.proficiencyLevel == proficiencyLevel) &&
            (identical(other.targetExam, targetExam) ||
                other.targetExam == targetExam) &&
            (identical(other.dailyGoalMinutes, dailyGoalMinutes) ||
                other.dailyGoalMinutes == dailyGoalMinutes) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    nativeLanguage,
    targetLanguage,
    proficiencyLevel,
    targetExam,
    dailyGoalMinutes,
    timezone,
  );

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingDataImplCopyWith<_$OnboardingDataImpl> get copyWith =>
      __$$OnboardingDataImplCopyWithImpl<_$OnboardingDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OnboardingDataImplToJson(this);
  }
}

abstract class _OnboardingData implements OnboardingData {
  const factory _OnboardingData({
    required final String nativeLanguage,
    required final String targetLanguage,
    required final String proficiencyLevel,
    final String? targetExam,
    required final int dailyGoalMinutes,
    final String? timezone,
  }) = _$OnboardingDataImpl;

  factory _OnboardingData.fromJson(Map<String, dynamic> json) =
      _$OnboardingDataImpl.fromJson;

  @override
  String get nativeLanguage;
  @override
  String get targetLanguage;
  @override
  String get proficiencyLevel;
  @override
  String? get targetExam;
  @override
  int get dailyGoalMinutes;
  @override
  String? get timezone;

  /// Create a copy of OnboardingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingDataImplCopyWith<_$OnboardingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
