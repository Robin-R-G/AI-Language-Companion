// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get badgeId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  DateTime get unlockedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
    Achievement value,
    $Res Function(Achievement) then,
  ) = _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call({
    String id,
    String userId,
    String badgeId,
    String title,
    String description,
    String iconName,
    int xpReward,
    String category,
    String tier,
    DateTime unlockedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? badgeId = null,
    Object? title = null,
    Object? description = null,
    Object? iconName = null,
    Object? xpReward = null,
    Object? category = null,
    Object? tier = null,
    Object? unlockedAt = null,
    Object? createdAt = null,
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
            badgeId: null == badgeId
                ? _value.badgeId
                : badgeId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            unlockedAt: null == unlockedAt
                ? _value.unlockedAt
                : unlockedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
    _$AchievementImpl value,
    $Res Function(_$AchievementImpl) then,
  ) = __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String badgeId,
    String title,
    String description,
    String iconName,
    int xpReward,
    String category,
    String tier,
    DateTime unlockedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
    _$AchievementImpl _value,
    $Res Function(_$AchievementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? badgeId = null,
    Object? title = null,
    Object? description = null,
    Object? iconName = null,
    Object? xpReward = null,
    Object? category = null,
    Object? tier = null,
    Object? unlockedAt = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AchievementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        badgeId: null == badgeId
            ? _value.badgeId
            : badgeId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        unlockedAt: null == unlockedAt
            ? _value.unlockedAt
            : unlockedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$AchievementImpl implements _Achievement {
  const _$AchievementImpl({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.title,
    required this.description,
    required this.iconName,
    required this.xpReward,
    required this.category,
    required this.tier,
    required this.unlockedAt,
    required this.createdAt,
  });

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String badgeId;
  @override
  final String title;
  @override
  final String description;
  @override
  final String iconName;
  @override
  final int xpReward;
  @override
  final String category;
  @override
  final String tier;
  @override
  final DateTime unlockedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Achievement(id: $id, userId: $userId, badgeId: $badgeId, title: $title, description: $description, iconName: $iconName, xpReward: $xpReward, category: $category, tier: $tier, unlockedAt: $unlockedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    badgeId,
    title,
    description,
    iconName,
    xpReward,
    category,
    tier,
    unlockedAt,
    createdAt,
  );

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(this);
  }
}

abstract class _Achievement implements Achievement {
  const factory _Achievement({
    required final String id,
    required final String userId,
    required final String badgeId,
    required final String title,
    required final String description,
    required final String iconName,
    required final int xpReward,
    required final String category,
    required final String tier,
    required final DateTime unlockedAt,
    required final DateTime createdAt,
  }) = _$AchievementImpl;

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get badgeId;
  @override
  String get title;
  @override
  String get description;
  @override
  String get iconName;
  @override
  int get xpReward;
  @override
  String get category;
  @override
  String get tier;
  @override
  DateTime get unlockedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  Map<String, dynamic> get criteria => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Badge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String iconName,
    int xpReward,
    String category,
    String tier,
    Map<String, dynamic> criteria,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconName = null,
    Object? xpReward = null,
    Object? category = null,
    Object? tier = null,
    Object? criteria = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            xpReward: null == xpReward
                ? _value.xpReward
                : xpReward // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            criteria: null == criteria
                ? _value.criteria
                : criteria // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
    _$BadgeImpl value,
    $Res Function(_$BadgeImpl) then,
  ) = __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String iconName,
    int xpReward,
    String category,
    String tier,
    Map<String, dynamic> criteria,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
    _$BadgeImpl _value,
    $Res Function(_$BadgeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconName = null,
    Object? xpReward = null,
    Object? category = null,
    Object? tier = null,
    Object? criteria = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$BadgeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        xpReward: null == xpReward
            ? _value.xpReward
            : xpReward // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        criteria: null == criteria
            ? _value._criteria
            : criteria // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$BadgeImpl implements _Badge {
  const _$BadgeImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.xpReward,
    required this.category,
    required this.tier,
    required final Map<String, dynamic> criteria,
    required this.isActive,
    required this.createdAt,
  }) : _criteria = criteria;

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String iconName;
  @override
  final int xpReward;
  @override
  final String category;
  @override
  final String tier;
  final Map<String, dynamic> _criteria;
  @override
  Map<String, dynamic> get criteria {
    if (_criteria is EqualUnmodifiableMapView) return _criteria;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_criteria);
  }

  @override
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Badge(id: $id, name: $name, description: $description, iconName: $iconName, xpReward: $xpReward, category: $category, tier: $tier, criteria: $criteria, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            const DeepCollectionEquality().equals(other._criteria, _criteria) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    iconName,
    xpReward,
    category,
    tier,
    const DeepCollectionEquality().hash(_criteria),
    isActive,
    createdAt,
  );

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(this);
  }
}

abstract class _Badge implements Badge {
  const factory _Badge({
    required final String id,
    required final String name,
    required final String description,
    required final String iconName,
    required final int xpReward,
    required final String category,
    required final String tier,
    required final Map<String, dynamic> criteria,
    required final bool isActive,
    required final DateTime createdAt,
  }) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get iconName;
  @override
  int get xpReward;
  @override
  String get category;
  @override
  String get tier;
  @override
  Map<String, dynamic> get criteria;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeagueStanding _$LeagueStandingFromJson(Map<String, dynamic> json) {
  return _LeagueStanding.fromJson(json);
}

/// @nodoc
mixin _$LeagueStanding {
  String get userId => throw _privateConstructorUsedError;
  String get leagueId => throw _privateConstructorUsedError;
  String get leagueName => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get previousRank => throw _privateConstructorUsedError;
  String get tier => throw _privateConstructorUsedError;
  DateTime get weekStart => throw _privateConstructorUsedError;
  DateTime get weekEnd => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LeagueStanding to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeagueStanding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeagueStandingCopyWith<LeagueStanding> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeagueStandingCopyWith<$Res> {
  factory $LeagueStandingCopyWith(
    LeagueStanding value,
    $Res Function(LeagueStanding) then,
  ) = _$LeagueStandingCopyWithImpl<$Res, LeagueStanding>;
  @useResult
  $Res call({
    String userId,
    String leagueId,
    String leagueName,
    int rank,
    int xp,
    int previousRank,
    String tier,
    DateTime weekStart,
    DateTime weekEnd,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LeagueStandingCopyWithImpl<$Res, $Val extends LeagueStanding>
    implements $LeagueStandingCopyWith<$Res> {
  _$LeagueStandingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeagueStanding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? leagueId = null,
    Object? leagueName = null,
    Object? rank = null,
    Object? xp = null,
    Object? previousRank = null,
    Object? tier = null,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            leagueId: null == leagueId
                ? _value.leagueId
                : leagueId // ignore: cast_nullable_to_non_nullable
                      as String,
            leagueName: null == leagueName
                ? _value.leagueName
                : leagueName // ignore: cast_nullable_to_non_nullable
                      as String,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            previousRank: null == previousRank
                ? _value.previousRank
                : previousRank // ignore: cast_nullable_to_non_nullable
                      as int,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as String,
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weekEnd: null == weekEnd
                ? _value.weekEnd
                : weekEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$LeagueStandingImplCopyWith<$Res>
    implements $LeagueStandingCopyWith<$Res> {
  factory _$$LeagueStandingImplCopyWith(
    _$LeagueStandingImpl value,
    $Res Function(_$LeagueStandingImpl) then,
  ) = __$$LeagueStandingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String leagueId,
    String leagueName,
    int rank,
    int xp,
    int previousRank,
    String tier,
    DateTime weekStart,
    DateTime weekEnd,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LeagueStandingImplCopyWithImpl<$Res>
    extends _$LeagueStandingCopyWithImpl<$Res, _$LeagueStandingImpl>
    implements _$$LeagueStandingImplCopyWith<$Res> {
  __$$LeagueStandingImplCopyWithImpl(
    _$LeagueStandingImpl _value,
    $Res Function(_$LeagueStandingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeagueStanding
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? leagueId = null,
    Object? leagueName = null,
    Object? rank = null,
    Object? xp = null,
    Object? previousRank = null,
    Object? tier = null,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LeagueStandingImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        leagueId: null == leagueId
            ? _value.leagueId
            : leagueId // ignore: cast_nullable_to_non_nullable
                  as String,
        leagueName: null == leagueName
            ? _value.leagueName
            : leagueName // ignore: cast_nullable_to_non_nullable
                  as String,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        previousRank: null == previousRank
            ? _value.previousRank
            : previousRank // ignore: cast_nullable_to_non_nullable
                  as int,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as String,
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weekEnd: null == weekEnd
            ? _value.weekEnd
            : weekEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$LeagueStandingImpl implements _LeagueStanding {
  const _$LeagueStandingImpl({
    required this.userId,
    required this.leagueId,
    required this.leagueName,
    required this.rank,
    required this.xp,
    required this.previousRank,
    required this.tier,
    required this.weekStart,
    required this.weekEnd,
    required this.createdAt,
  });

  factory _$LeagueStandingImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeagueStandingImplFromJson(json);

  @override
  final String userId;
  @override
  final String leagueId;
  @override
  final String leagueName;
  @override
  final int rank;
  @override
  final int xp;
  @override
  final int previousRank;
  @override
  final String tier;
  @override
  final DateTime weekStart;
  @override
  final DateTime weekEnd;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LeagueStanding(userId: $userId, leagueId: $leagueId, leagueName: $leagueName, rank: $rank, xp: $xp, previousRank: $previousRank, tier: $tier, weekStart: $weekStart, weekEnd: $weekEnd, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeagueStandingImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.leagueId, leagueId) ||
                other.leagueId == leagueId) &&
            (identical(other.leagueName, leagueName) ||
                other.leagueName == leagueName) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.previousRank, previousRank) ||
                other.previousRank == previousRank) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    leagueId,
    leagueName,
    rank,
    xp,
    previousRank,
    tier,
    weekStart,
    weekEnd,
    createdAt,
  );

  /// Create a copy of LeagueStanding
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeagueStandingImplCopyWith<_$LeagueStandingImpl> get copyWith =>
      __$$LeagueStandingImplCopyWithImpl<_$LeagueStandingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeagueStandingImplToJson(this);
  }
}

abstract class _LeagueStanding implements LeagueStanding {
  const factory _LeagueStanding({
    required final String userId,
    required final String leagueId,
    required final String leagueName,
    required final int rank,
    required final int xp,
    required final int previousRank,
    required final String tier,
    required final DateTime weekStart,
    required final DateTime weekEnd,
    required final DateTime createdAt,
  }) = _$LeagueStandingImpl;

  factory _LeagueStanding.fromJson(Map<String, dynamic> json) =
      _$LeagueStandingImpl.fromJson;

  @override
  String get userId;
  @override
  String get leagueId;
  @override
  String get leagueName;
  @override
  int get rank;
  @override
  int get xp;
  @override
  int get previousRank;
  @override
  String get tier;
  @override
  DateTime get weekStart;
  @override
  DateTime get weekEnd;
  @override
  DateTime get createdAt;

  /// Create a copy of LeagueStanding
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeagueStandingImplCopyWith<_$LeagueStandingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) {
  return _LeaderboardEntry.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntry {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryCopyWith<LeaderboardEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryCopyWith<$Res> {
  factory $LeaderboardEntryCopyWith(
    LeaderboardEntry value,
    $Res Function(LeaderboardEntry) then,
  ) = _$LeaderboardEntryCopyWithImpl<$Res, LeaderboardEntry>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String? avatarUrl,
    int rank,
    int xp,
    int streak,
    int level,
  });
}

/// @nodoc
class _$LeaderboardEntryCopyWithImpl<$Res, $Val extends LeaderboardEntry>
    implements $LeaderboardEntryCopyWith<$Res> {
  _$LeaderboardEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? avatarUrl = freezed,
    Object? rank = null,
    Object? xp = null,
    Object? streak = null,
    Object? level = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryImplCopyWith<$Res>
    implements $LeaderboardEntryCopyWith<$Res> {
  factory _$$LeaderboardEntryImplCopyWith(
    _$LeaderboardEntryImpl value,
    $Res Function(_$LeaderboardEntryImpl) then,
  ) = __$$LeaderboardEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String? avatarUrl,
    int rank,
    int xp,
    int streak,
    int level,
  });
}

/// @nodoc
class __$$LeaderboardEntryImplCopyWithImpl<$Res>
    extends _$LeaderboardEntryCopyWithImpl<$Res, _$LeaderboardEntryImpl>
    implements _$$LeaderboardEntryImplCopyWith<$Res> {
  __$$LeaderboardEntryImplCopyWithImpl(
    _$LeaderboardEntryImpl _value,
    $Res Function(_$LeaderboardEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? avatarUrl = freezed,
    Object? rank = null,
    Object? xp = null,
    Object? streak = null,
    Object? level = null,
  }) {
    return _then(
      _$LeaderboardEntryImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryImpl implements _LeaderboardEntry {
  const _$LeaderboardEntryImpl({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.rank,
    required this.xp,
    required this.streak,
    required this.level,
  });

  factory _$LeaderboardEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? avatarUrl;
  @override
  final int rank;
  @override
  final int xp;
  @override
  final int streak;
  @override
  final int level;

  @override
  String toString() {
    return 'LeaderboardEntry(userId: $userId, userName: $userName, avatarUrl: $avatarUrl, rank: $rank, xp: $xp, streak: $streak, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    avatarUrl,
    rank,
    xp,
    streak,
    level,
  );

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      __$$LeaderboardEntryImplCopyWithImpl<_$LeaderboardEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryImplToJson(this);
  }
}

abstract class _LeaderboardEntry implements LeaderboardEntry {
  const factory _LeaderboardEntry({
    required final String userId,
    required final String userName,
    required final String? avatarUrl,
    required final int rank,
    required final int xp,
    required final int streak,
    required final int level,
  }) = _$LeaderboardEntryImpl;

  factory _LeaderboardEntry.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get avatarUrl;
  @override
  int get rank;
  @override
  int get xp;
  @override
  int get streak;
  @override
  int get level;

  /// Create a copy of LeaderboardEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryImplCopyWith<_$LeaderboardEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
