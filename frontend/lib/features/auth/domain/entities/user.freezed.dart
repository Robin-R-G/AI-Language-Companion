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
  String get displayName => throw _privateConstructorUsedError;
  String get avatarUrl => throw _privateConstructorUsedError;
  String get nativeLanguage => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String get proficiencyLevel => throw _privateConstructorUsedError;
  String get targetExam => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get lessonsCompleted => throw _privateConstructorUsedError;
  int get voiceSessionsCompleted => throw _privateConstructorUsedError;
  int get mockExamsCompleted => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  bool get isOnboardingComplete => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  String get subscriptionPlan => throw _privateConstructorUsedError;
  Map<String, dynamic> get preferences => throw _privateConstructorUsedError;

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
    String displayName,
    String avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String proficiencyLevel,
    String targetExam,
    int xp,
    int streak,
    int level,
    int lessonsCompleted,
    int voiceSessionsCompleted,
    int mockExamsCompleted,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    bool isOnboardingComplete,
    bool isPremium,
    String subscriptionPlan,
    Map<String, dynamic> preferences,
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
    Object? displayName = null,
    Object? avatarUrl = null,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = null,
    Object? targetExam = null,
    Object? xp = null,
    Object? streak = null,
    Object? level = null,
    Object? lessonsCompleted = null,
    Object? voiceSessionsCompleted = null,
    Object? mockExamsCompleted = null,
    Object? lastActiveAt = freezed,
    Object? createdAt = freezed,
    Object? isOnboardingComplete = null,
    Object? isPremium = null,
    Object? subscriptionPlan = null,
    Object? preferences = null,
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
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: null == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String,
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
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            streak: null == streak
                ? _value.streak
                : streak // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            lessonsCompleted: null == lessonsCompleted
                ? _value.lessonsCompleted
                : lessonsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            voiceSessionsCompleted: null == voiceSessionsCompleted
                ? _value.voiceSessionsCompleted
                : voiceSessionsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            mockExamsCompleted: null == mockExamsCompleted
                ? _value.mockExamsCompleted
                : mockExamsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            lastActiveAt: freezed == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isOnboardingComplete: null == isOnboardingComplete
                ? _value.isOnboardingComplete
                : isOnboardingComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            subscriptionPlan: null == subscriptionPlan
                ? _value.subscriptionPlan
                : subscriptionPlan // ignore: cast_nullable_to_non_nullable
                      as String,
            preferences: null == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
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
    String displayName,
    String avatarUrl,
    String nativeLanguage,
    String targetLanguage,
    String proficiencyLevel,
    String targetExam,
    int xp,
    int streak,
    int level,
    int lessonsCompleted,
    int voiceSessionsCompleted,
    int mockExamsCompleted,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    bool isOnboardingComplete,
    bool isPremium,
    String subscriptionPlan,
    Map<String, dynamic> preferences,
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
    Object? displayName = null,
    Object? avatarUrl = null,
    Object? nativeLanguage = null,
    Object? targetLanguage = null,
    Object? proficiencyLevel = null,
    Object? targetExam = null,
    Object? xp = null,
    Object? streak = null,
    Object? level = null,
    Object? lessonsCompleted = null,
    Object? voiceSessionsCompleted = null,
    Object? mockExamsCompleted = null,
    Object? lastActiveAt = freezed,
    Object? createdAt = freezed,
    Object? isOnboardingComplete = null,
    Object? isPremium = null,
    Object? subscriptionPlan = null,
    Object? preferences = null,
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
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: null == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String,
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
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        streak: null == streak
            ? _value.streak
            : streak // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        lessonsCompleted: null == lessonsCompleted
            ? _value.lessonsCompleted
            : lessonsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        voiceSessionsCompleted: null == voiceSessionsCompleted
            ? _value.voiceSessionsCompleted
            : voiceSessionsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        mockExamsCompleted: null == mockExamsCompleted
            ? _value.mockExamsCompleted
            : mockExamsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        lastActiveAt: freezed == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isOnboardingComplete: null == isOnboardingComplete
            ? _value.isOnboardingComplete
            : isOnboardingComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        subscriptionPlan: null == subscriptionPlan
            ? _value.subscriptionPlan
            : subscriptionPlan // ignore: cast_nullable_to_non_nullable
                  as String,
        preferences: null == preferences
            ? _value._preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
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
    this.displayName = '',
    this.avatarUrl = '',
    this.nativeLanguage = '',
    this.targetLanguage = 'en',
    this.proficiencyLevel = 'A1',
    this.targetExam = 'general',
    this.xp = 0,
    this.streak = 0,
    this.level = 0,
    this.lessonsCompleted = 0,
    this.voiceSessionsCompleted = 0,
    this.mockExamsCompleted = 0,
    this.lastActiveAt,
    this.createdAt,
    this.isOnboardingComplete = false,
    this.isPremium = false,
    this.subscriptionPlan = 'free',
    final Map<String, dynamic> preferences = const {},
  }) : _preferences = preferences;

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  @JsonKey()
  final String displayName;
  @override
  @JsonKey()
  final String avatarUrl;
  @override
  @JsonKey()
  final String nativeLanguage;
  @override
  @JsonKey()
  final String targetLanguage;
  @override
  @JsonKey()
  final String proficiencyLevel;
  @override
  @JsonKey()
  final String targetExam;
  @override
  @JsonKey()
  final int xp;
  @override
  @JsonKey()
  final int streak;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int lessonsCompleted;
  @override
  @JsonKey()
  final int voiceSessionsCompleted;
  @override
  @JsonKey()
  final int mockExamsCompleted;
  @override
  final DateTime? lastActiveAt;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final bool isOnboardingComplete;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final String subscriptionPlan;
  final Map<String, dynamic> _preferences;
  @override
  @JsonKey()
  Map<String, dynamic> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, nativeLanguage: $nativeLanguage, targetLanguage: $targetLanguage, proficiencyLevel: $proficiencyLevel, targetExam: $targetExam, xp: $xp, streak: $streak, level: $level, lessonsCompleted: $lessonsCompleted, voiceSessionsCompleted: $voiceSessionsCompleted, mockExamsCompleted: $mockExamsCompleted, lastActiveAt: $lastActiveAt, createdAt: $createdAt, isOnboardingComplete: $isOnboardingComplete, isPremium: $isPremium, subscriptionPlan: $subscriptionPlan, preferences: $preferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
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
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.lessonsCompleted, lessonsCompleted) ||
                other.lessonsCompleted == lessonsCompleted) &&
            (identical(other.voiceSessionsCompleted, voiceSessionsCompleted) ||
                other.voiceSessionsCompleted == voiceSessionsCompleted) &&
            (identical(other.mockExamsCompleted, mockExamsCompleted) ||
                other.mockExamsCompleted == mockExamsCompleted) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isOnboardingComplete, isOnboardingComplete) ||
                other.isOnboardingComplete == isOnboardingComplete) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.subscriptionPlan, subscriptionPlan) ||
                other.subscriptionPlan == subscriptionPlan) &&
            const DeepCollectionEquality().equals(
              other._preferences,
              _preferences,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    email,
    displayName,
    avatarUrl,
    nativeLanguage,
    targetLanguage,
    proficiencyLevel,
    targetExam,
    xp,
    streak,
    level,
    lessonsCompleted,
    voiceSessionsCompleted,
    mockExamsCompleted,
    lastActiveAt,
    createdAt,
    isOnboardingComplete,
    isPremium,
    subscriptionPlan,
    const DeepCollectionEquality().hash(_preferences),
  ]);

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
    final String displayName,
    final String avatarUrl,
    final String nativeLanguage,
    final String targetLanguage,
    final String proficiencyLevel,
    final String targetExam,
    final int xp,
    final int streak,
    final int level,
    final int lessonsCompleted,
    final int voiceSessionsCompleted,
    final int mockExamsCompleted,
    final DateTime? lastActiveAt,
    final DateTime? createdAt,
    final bool isOnboardingComplete,
    final bool isPremium,
    final String subscriptionPlan,
    final Map<String, dynamic> preferences,
  }) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get displayName;
  @override
  String get avatarUrl;
  @override
  String get nativeLanguage;
  @override
  String get targetLanguage;
  @override
  String get proficiencyLevel;
  @override
  String get targetExam;
  @override
  int get xp;
  @override
  int get streak;
  @override
  int get level;
  @override
  int get lessonsCompleted;
  @override
  int get voiceSessionsCompleted;
  @override
  int get mockExamsCompleted;
  @override
  DateTime? get lastActiveAt;
  @override
  DateTime? get createdAt;
  @override
  bool get isOnboardingComplete;
  @override
  bool get isPremium;
  @override
  String get subscriptionPlan;
  @override
  Map<String, dynamic> get preferences;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
