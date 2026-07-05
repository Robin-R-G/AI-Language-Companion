// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  String get planName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get billingCycle => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime get currentPeriodStart => throw _privateConstructorUsedError;
  DateTime get currentPeriodEnd => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  DateTime? get trialEnd => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String id,
    String userId,
    String provider,
    String planId,
    String planName,
    String status,
    String billingCycle,
    double amount,
    String currency,
    DateTime currentPeriodStart,
    DateTime currentPeriodEnd,
    DateTime? cancelledAt,
    DateTime? trialEnd,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? provider = null,
    Object? planId = null,
    Object? planName = null,
    Object? status = null,
    Object? billingCycle = null,
    Object? amount = null,
    Object? currency = null,
    Object? currentPeriodStart = null,
    Object? currentPeriodEnd = null,
    Object? cancelledAt = freezed,
    Object? trialEnd = freezed,
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
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            planId: null == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                      as String,
            planName: null == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            billingCycle: null == billingCycle
                ? _value.billingCycle
                : billingCycle // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPeriodStart: null == currentPeriodStart
                ? _value.currentPeriodStart
                : currentPeriodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            currentPeriodEnd: null == currentPeriodEnd
                ? _value.currentPeriodEnd
                : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            trialEnd: freezed == trialEnd
                ? _value.trialEnd
                : trialEnd // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String provider,
    String planId,
    String planName,
    String status,
    String billingCycle,
    double amount,
    String currency,
    DateTime currentPeriodStart,
    DateTime currentPeriodEnd,
    DateTime? cancelledAt,
    DateTime? trialEnd,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? provider = null,
    Object? planId = null,
    Object? planName = null,
    Object? status = null,
    Object? billingCycle = null,
    Object? amount = null,
    Object? currency = null,
    Object? currentPeriodStart = null,
    Object? currentPeriodEnd = null,
    Object? cancelledAt = freezed,
    Object? trialEnd = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubscriptionImpl(
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
        planId: null == planId
            ? _value.planId
            : planId // ignore: cast_nullable_to_non_nullable
                  as String,
        planName: null == planName
            ? _value.planName
            : planName // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        billingCycle: null == billingCycle
            ? _value.billingCycle
            : billingCycle // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPeriodStart: null == currentPeriodStart
            ? _value.currentPeriodStart
            : currentPeriodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        currentPeriodEnd: null == currentPeriodEnd
            ? _value.currentPeriodEnd
            : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        trialEnd: freezed == trialEnd
            ? _value.trialEnd
            : trialEnd // ignore: cast_nullable_to_non_nullable
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
class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl({
    required this.id,
    required this.userId,
    required this.provider,
    required this.planId,
    required this.planName,
    required this.status,
    required this.billingCycle,
    required this.amount,
    required this.currency,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelledAt,
    this.trialEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String provider;
  @override
  final String planId;
  @override
  final String planName;
  @override
  final String status;
  @override
  final String billingCycle;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final DateTime currentPeriodStart;
  @override
  final DateTime currentPeriodEnd;
  @override
  final DateTime? cancelledAt;
  @override
  final DateTime? trialEnd;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Subscription(id: $id, userId: $userId, provider: $provider, planId: $planId, planName: $planName, status: $status, billingCycle: $billingCycle, amount: $amount, currency: $currency, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, cancelledAt: $cancelledAt, trialEnd: $trialEnd, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.billingCycle, billingCycle) ||
                other.billingCycle == billingCycle) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.currentPeriodStart, currentPeriodStart) ||
                other.currentPeriodStart == currentPeriodStart) &&
            (identical(other.currentPeriodEnd, currentPeriodEnd) ||
                other.currentPeriodEnd == currentPeriodEnd) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.trialEnd, trialEnd) ||
                other.trialEnd == trialEnd) &&
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
    provider,
    planId,
    planName,
    status,
    billingCycle,
    amount,
    currency,
    currentPeriodStart,
    currentPeriodEnd,
    cancelledAt,
    trialEnd,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription implements Subscription {
  const factory _Subscription({
    required final String id,
    required final String userId,
    required final String provider,
    required final String planId,
    required final String planName,
    required final String status,
    required final String billingCycle,
    required final double amount,
    required final String currency,
    required final DateTime currentPeriodStart,
    required final DateTime currentPeriodEnd,
    final DateTime? cancelledAt,
    final DateTime? trialEnd,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SubscriptionImpl;

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get provider;
  @override
  String get planId;
  @override
  String get planName;
  @override
  String get status;
  @override
  String get billingCycle;
  @override
  double get amount;
  @override
  String get currency;
  @override
  DateTime get currentPeriodStart;
  @override
  DateTime get currentPeriodEnd;
  @override
  DateTime? get cancelledAt;
  @override
  DateTime? get trialEnd;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) {
  return _SubscriptionPlan.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get monthlyPrice => throw _privateConstructorUsedError;
  double get annualPrice => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;
  int get dailyVoiceMinutes => throw _privateConstructorUsedError;
  int get dailyLessons => throw _privateConstructorUsedError;
  int get monthlyMockExams => throw _privateConstructorUsedError;
  bool get hasPrioritySupport => throw _privateConstructorUsedError;
  bool get hasAdvancedAnalytics => throw _privateConstructorUsedError;
  bool get hasOfflineMode => throw _privateConstructorUsedError;
  bool get isPopular => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionPlanCopyWith<SubscriptionPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionPlanCopyWith<$Res> {
  factory $SubscriptionPlanCopyWith(
    SubscriptionPlan value,
    $Res Function(SubscriptionPlan) then,
  ) = _$SubscriptionPlanCopyWithImpl<$Res, SubscriptionPlan>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    double monthlyPrice,
    double annualPrice,
    String currency,
    List<String> features,
    int dailyVoiceMinutes,
    int dailyLessons,
    int monthlyMockExams,
    bool hasPrioritySupport,
    bool hasAdvancedAnalytics,
    bool hasOfflineMode,
    bool isPopular,
    int sortOrder,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubscriptionPlanCopyWithImpl<$Res, $Val extends SubscriptionPlan>
    implements $SubscriptionPlanCopyWith<$Res> {
  _$SubscriptionPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? monthlyPrice = null,
    Object? annualPrice = null,
    Object? currency = null,
    Object? features = null,
    Object? dailyVoiceMinutes = null,
    Object? dailyLessons = null,
    Object? monthlyMockExams = null,
    Object? hasPrioritySupport = null,
    Object? hasAdvancedAnalytics = null,
    Object? hasOfflineMode = null,
    Object? isPopular = null,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            monthlyPrice: null == monthlyPrice
                ? _value.monthlyPrice
                : monthlyPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            annualPrice: null == annualPrice
                ? _value.annualPrice
                : annualPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            features: null == features
                ? _value.features
                : features // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dailyVoiceMinutes: null == dailyVoiceMinutes
                ? _value.dailyVoiceMinutes
                : dailyVoiceMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyLessons: null == dailyLessons
                ? _value.dailyLessons
                : dailyLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyMockExams: null == monthlyMockExams
                ? _value.monthlyMockExams
                : monthlyMockExams // ignore: cast_nullable_to_non_nullable
                      as int,
            hasPrioritySupport: null == hasPrioritySupport
                ? _value.hasPrioritySupport
                : hasPrioritySupport // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasAdvancedAnalytics: null == hasAdvancedAnalytics
                ? _value.hasAdvancedAnalytics
                : hasAdvancedAnalytics // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasOfflineMode: null == hasOfflineMode
                ? _value.hasOfflineMode
                : hasOfflineMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPopular: null == isPopular
                ? _value.isPopular
                : isPopular // ignore: cast_nullable_to_non_nullable
                      as bool,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$SubscriptionPlanImplCopyWith<$Res>
    implements $SubscriptionPlanCopyWith<$Res> {
  factory _$$SubscriptionPlanImplCopyWith(
    _$SubscriptionPlanImpl value,
    $Res Function(_$SubscriptionPlanImpl) then,
  ) = __$$SubscriptionPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    double monthlyPrice,
    double annualPrice,
    String currency,
    List<String> features,
    int dailyVoiceMinutes,
    int dailyLessons,
    int monthlyMockExams,
    bool hasPrioritySupport,
    bool hasAdvancedAnalytics,
    bool hasOfflineMode,
    bool isPopular,
    int sortOrder,
    bool isActive,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubscriptionPlanImplCopyWithImpl<$Res>
    extends _$SubscriptionPlanCopyWithImpl<$Res, _$SubscriptionPlanImpl>
    implements _$$SubscriptionPlanImplCopyWith<$Res> {
  __$$SubscriptionPlanImplCopyWithImpl(
    _$SubscriptionPlanImpl _value,
    $Res Function(_$SubscriptionPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? monthlyPrice = null,
    Object? annualPrice = null,
    Object? currency = null,
    Object? features = null,
    Object? dailyVoiceMinutes = null,
    Object? dailyLessons = null,
    Object? monthlyMockExams = null,
    Object? hasPrioritySupport = null,
    Object? hasAdvancedAnalytics = null,
    Object? hasOfflineMode = null,
    Object? isPopular = null,
    Object? sortOrder = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubscriptionPlanImpl(
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
        monthlyPrice: null == monthlyPrice
            ? _value.monthlyPrice
            : monthlyPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        annualPrice: null == annualPrice
            ? _value.annualPrice
            : annualPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        features: null == features
            ? _value._features
            : features // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dailyVoiceMinutes: null == dailyVoiceMinutes
            ? _value.dailyVoiceMinutes
            : dailyVoiceMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyLessons: null == dailyLessons
            ? _value.dailyLessons
            : dailyLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyMockExams: null == monthlyMockExams
            ? _value.monthlyMockExams
            : monthlyMockExams // ignore: cast_nullable_to_non_nullable
                  as int,
        hasPrioritySupport: null == hasPrioritySupport
            ? _value.hasPrioritySupport
            : hasPrioritySupport // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasAdvancedAnalytics: null == hasAdvancedAnalytics
            ? _value.hasAdvancedAnalytics
            : hasAdvancedAnalytics // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasOfflineMode: null == hasOfflineMode
            ? _value.hasOfflineMode
            : hasOfflineMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPopular: null == isPopular
            ? _value.isPopular
            : isPopular // ignore: cast_nullable_to_non_nullable
                  as bool,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$SubscriptionPlanImpl implements _SubscriptionPlan {
  const _$SubscriptionPlanImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.currency,
    required final List<String> features,
    required this.dailyVoiceMinutes,
    required this.dailyLessons,
    required this.monthlyMockExams,
    required this.hasPrioritySupport,
    required this.hasAdvancedAnalytics,
    required this.hasOfflineMode,
    required this.isPopular,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  }) : _features = features;

  factory _$SubscriptionPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double monthlyPrice;
  @override
  final double annualPrice;
  @override
  final String currency;
  final List<String> _features;
  @override
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  final int dailyVoiceMinutes;
  @override
  final int dailyLessons;
  @override
  final int monthlyMockExams;
  @override
  final bool hasPrioritySupport;
  @override
  final bool hasAdvancedAnalytics;
  @override
  final bool hasOfflineMode;
  @override
  final bool isPopular;
  @override
  final int sortOrder;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SubscriptionPlan(id: $id, name: $name, description: $description, monthlyPrice: $monthlyPrice, annualPrice: $annualPrice, currency: $currency, features: $features, dailyVoiceMinutes: $dailyVoiceMinutes, dailyLessons: $dailyLessons, monthlyMockExams: $monthlyMockExams, hasPrioritySupport: $hasPrioritySupport, hasAdvancedAnalytics: $hasAdvancedAnalytics, hasOfflineMode: $hasOfflineMode, isPopular: $isPopular, sortOrder: $sortOrder, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.monthlyPrice, monthlyPrice) ||
                other.monthlyPrice == monthlyPrice) &&
            (identical(other.annualPrice, annualPrice) ||
                other.annualPrice == annualPrice) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.dailyVoiceMinutes, dailyVoiceMinutes) ||
                other.dailyVoiceMinutes == dailyVoiceMinutes) &&
            (identical(other.dailyLessons, dailyLessons) ||
                other.dailyLessons == dailyLessons) &&
            (identical(other.monthlyMockExams, monthlyMockExams) ||
                other.monthlyMockExams == monthlyMockExams) &&
            (identical(other.hasPrioritySupport, hasPrioritySupport) ||
                other.hasPrioritySupport == hasPrioritySupport) &&
            (identical(other.hasAdvancedAnalytics, hasAdvancedAnalytics) ||
                other.hasAdvancedAnalytics == hasAdvancedAnalytics) &&
            (identical(other.hasOfflineMode, hasOfflineMode) ||
                other.hasOfflineMode == hasOfflineMode) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    name,
    description,
    monthlyPrice,
    annualPrice,
    currency,
    const DeepCollectionEquality().hash(_features),
    dailyVoiceMinutes,
    dailyLessons,
    monthlyMockExams,
    hasPrioritySupport,
    hasAdvancedAnalytics,
    hasOfflineMode,
    isPopular,
    sortOrder,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionPlanImplCopyWith<_$SubscriptionPlanImpl> get copyWith =>
      __$$SubscriptionPlanImplCopyWithImpl<_$SubscriptionPlanImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionPlanImplToJson(this);
  }
}

abstract class _SubscriptionPlan implements SubscriptionPlan {
  const factory _SubscriptionPlan({
    required final String id,
    required final String name,
    required final String description,
    required final double monthlyPrice,
    required final double annualPrice,
    required final String currency,
    required final List<String> features,
    required final int dailyVoiceMinutes,
    required final int dailyLessons,
    required final int monthlyMockExams,
    required final bool hasPrioritySupport,
    required final bool hasAdvancedAnalytics,
    required final bool hasOfflineMode,
    required final bool isPopular,
    required final int sortOrder,
    required final bool isActive,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SubscriptionPlanImpl;

  factory _SubscriptionPlan.fromJson(Map<String, dynamic> json) =
      _$SubscriptionPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get monthlyPrice;
  @override
  double get annualPrice;
  @override
  String get currency;
  @override
  List<String> get features;
  @override
  int get dailyVoiceMinutes;
  @override
  int get dailyLessons;
  @override
  int get monthlyMockExams;
  @override
  bool get hasPrioritySupport;
  @override
  bool get hasAdvancedAnalytics;
  @override
  bool get hasOfflineMode;
  @override
  bool get isPopular;
  @override
  int get sortOrder;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SubscriptionPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionPlanImplCopyWith<_$SubscriptionPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get subscriptionId => throw _privateConstructorUsedError;
  String get transactionId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call({
    String id,
    String userId,
    String subscriptionId,
    String transactionId,
    double amount,
    String currency,
    String platform,
    String status,
    Map<String, dynamic> metadata,
    DateTime createdAt,
  });
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? transactionId = null,
    Object? amount = null,
    Object? currency = null,
    Object? platform = null,
    Object? status = null,
    Object? metadata = null,
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
            subscriptionId: null == subscriptionId
                ? _value.subscriptionId
                : subscriptionId // ignore: cast_nullable_to_non_nullable
                      as String,
            transactionId: null == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
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
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
    _$PaymentImpl value,
    $Res Function(_$PaymentImpl) then,
  ) = __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String subscriptionId,
    String transactionId,
    double amount,
    String currency,
    String platform,
    String status,
    Map<String, dynamic> metadata,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
    _$PaymentImpl _value,
    $Res Function(_$PaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subscriptionId = null,
    Object? transactionId = null,
    Object? amount = null,
    Object? currency = null,
    Object? platform = null,
    Object? status = null,
    Object? metadata = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PaymentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        subscriptionId: null == subscriptionId
            ? _value.subscriptionId
            : subscriptionId // ignore: cast_nullable_to_non_nullable
                  as String,
        transactionId: null == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
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
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.platform,
    required this.status,
    required final Map<String, dynamic> metadata,
    required this.createdAt,
  }) : _metadata = metadata;

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String subscriptionId;
  @override
  final String transactionId;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final String platform;
  @override
  final String status;
  final Map<String, dynamic> _metadata;
  @override
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Payment(id: $id, userId: $userId, subscriptionId: $subscriptionId, transactionId: $transactionId, amount: $amount, currency: $currency, platform: $platform, status: $status, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    subscriptionId,
    transactionId,
    amount,
    currency,
    platform,
    status,
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
  );

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(this);
  }
}

abstract class _Payment implements Payment {
  const factory _Payment({
    required final String id,
    required final String userId,
    required final String subscriptionId,
    required final String transactionId,
    required final double amount,
    required final String currency,
    required final String platform,
    required final String status,
    required final Map<String, dynamic> metadata,
    required final DateTime createdAt,
  }) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get subscriptionId;
  @override
  String get transactionId;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String get platform;
  @override
  String get status;
  @override
  Map<String, dynamic> get metadata;
  @override
  DateTime get createdAt;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Entitlement _$EntitlementFromJson(Map<String, dynamic> json) {
  return _Entitlement.fromJson(json);
}

/// @nodoc
mixin _$Entitlement {
  String get userId => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  bool get isPremiumPlus => throw _privateConstructorUsedError;
  int get dailyVoiceMinutesUsed => throw _privateConstructorUsedError;
  int get dailyVoiceMinutesLimit => throw _privateConstructorUsedError;
  int get dailyLessonsUsed => throw _privateConstructorUsedError;
  int get dailyLessonsLimit => throw _privateConstructorUsedError;
  int get monthlyMockExamsUsed => throw _privateConstructorUsedError;
  int get monthlyMockExamsLimit => throw _privateConstructorUsedError;
  DateTime get lastResetDate => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Entitlement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntitlementCopyWith<Entitlement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntitlementCopyWith<$Res> {
  factory $EntitlementCopyWith(
    Entitlement value,
    $Res Function(Entitlement) then,
  ) = _$EntitlementCopyWithImpl<$Res, Entitlement>;
  @useResult
  $Res call({
    String userId,
    bool isPremium,
    bool isPremiumPlus,
    int dailyVoiceMinutesUsed,
    int dailyVoiceMinutesLimit,
    int dailyLessonsUsed,
    int dailyLessonsLimit,
    int monthlyMockExamsUsed,
    int monthlyMockExamsLimit,
    DateTime lastResetDate,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$EntitlementCopyWithImpl<$Res, $Val extends Entitlement>
    implements $EntitlementCopyWith<$Res> {
  _$EntitlementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isPremium = null,
    Object? isPremiumPlus = null,
    Object? dailyVoiceMinutesUsed = null,
    Object? dailyVoiceMinutesLimit = null,
    Object? dailyLessonsUsed = null,
    Object? dailyLessonsLimit = null,
    Object? monthlyMockExamsUsed = null,
    Object? monthlyMockExamsLimit = null,
    Object? lastResetDate = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPremiumPlus: null == isPremiumPlus
                ? _value.isPremiumPlus
                : isPremiumPlus // ignore: cast_nullable_to_non_nullable
                      as bool,
            dailyVoiceMinutesUsed: null == dailyVoiceMinutesUsed
                ? _value.dailyVoiceMinutesUsed
                : dailyVoiceMinutesUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyVoiceMinutesLimit: null == dailyVoiceMinutesLimit
                ? _value.dailyVoiceMinutesLimit
                : dailyVoiceMinutesLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyLessonsUsed: null == dailyLessonsUsed
                ? _value.dailyLessonsUsed
                : dailyLessonsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            dailyLessonsLimit: null == dailyLessonsLimit
                ? _value.dailyLessonsLimit
                : dailyLessonsLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyMockExamsUsed: null == monthlyMockExamsUsed
                ? _value.monthlyMockExamsUsed
                : monthlyMockExamsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            monthlyMockExamsLimit: null == monthlyMockExamsLimit
                ? _value.monthlyMockExamsLimit
                : monthlyMockExamsLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            lastResetDate: null == lastResetDate
                ? _value.lastResetDate
                : lastResetDate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$EntitlementImplCopyWith<$Res>
    implements $EntitlementCopyWith<$Res> {
  factory _$$EntitlementImplCopyWith(
    _$EntitlementImpl value,
    $Res Function(_$EntitlementImpl) then,
  ) = __$$EntitlementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    bool isPremium,
    bool isPremiumPlus,
    int dailyVoiceMinutesUsed,
    int dailyVoiceMinutesLimit,
    int dailyLessonsUsed,
    int dailyLessonsLimit,
    int monthlyMockExamsUsed,
    int monthlyMockExamsLimit,
    DateTime lastResetDate,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$EntitlementImplCopyWithImpl<$Res>
    extends _$EntitlementCopyWithImpl<$Res, _$EntitlementImpl>
    implements _$$EntitlementImplCopyWith<$Res> {
  __$$EntitlementImplCopyWithImpl(
    _$EntitlementImpl _value,
    $Res Function(_$EntitlementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isPremium = null,
    Object? isPremiumPlus = null,
    Object? dailyVoiceMinutesUsed = null,
    Object? dailyVoiceMinutesLimit = null,
    Object? dailyLessonsUsed = null,
    Object? dailyLessonsLimit = null,
    Object? monthlyMockExamsUsed = null,
    Object? monthlyMockExamsLimit = null,
    Object? lastResetDate = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$EntitlementImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPremiumPlus: null == isPremiumPlus
            ? _value.isPremiumPlus
            : isPremiumPlus // ignore: cast_nullable_to_non_nullable
                  as bool,
        dailyVoiceMinutesUsed: null == dailyVoiceMinutesUsed
            ? _value.dailyVoiceMinutesUsed
            : dailyVoiceMinutesUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyVoiceMinutesLimit: null == dailyVoiceMinutesLimit
            ? _value.dailyVoiceMinutesLimit
            : dailyVoiceMinutesLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyLessonsUsed: null == dailyLessonsUsed
            ? _value.dailyLessonsUsed
            : dailyLessonsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        dailyLessonsLimit: null == dailyLessonsLimit
            ? _value.dailyLessonsLimit
            : dailyLessonsLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyMockExamsUsed: null == monthlyMockExamsUsed
            ? _value.monthlyMockExamsUsed
            : monthlyMockExamsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        monthlyMockExamsLimit: null == monthlyMockExamsLimit
            ? _value.monthlyMockExamsLimit
            : monthlyMockExamsLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        lastResetDate: null == lastResetDate
            ? _value.lastResetDate
            : lastResetDate // ignore: cast_nullable_to_non_nullable
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
class _$EntitlementImpl implements _Entitlement {
  const _$EntitlementImpl({
    required this.userId,
    required this.isPremium,
    required this.isPremiumPlus,
    required this.dailyVoiceMinutesUsed,
    required this.dailyVoiceMinutesLimit,
    required this.dailyLessonsUsed,
    required this.dailyLessonsLimit,
    required this.monthlyMockExamsUsed,
    required this.monthlyMockExamsLimit,
    required this.lastResetDate,
    required this.updatedAt,
  });

  factory _$EntitlementImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntitlementImplFromJson(json);

  @override
  final String userId;
  @override
  final bool isPremium;
  @override
  final bool isPremiumPlus;
  @override
  final int dailyVoiceMinutesUsed;
  @override
  final int dailyVoiceMinutesLimit;
  @override
  final int dailyLessonsUsed;
  @override
  final int dailyLessonsLimit;
  @override
  final int monthlyMockExamsUsed;
  @override
  final int monthlyMockExamsLimit;
  @override
  final DateTime lastResetDate;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Entitlement(userId: $userId, isPremium: $isPremium, isPremiumPlus: $isPremiumPlus, dailyVoiceMinutesUsed: $dailyVoiceMinutesUsed, dailyVoiceMinutesLimit: $dailyVoiceMinutesLimit, dailyLessonsUsed: $dailyLessonsUsed, dailyLessonsLimit: $dailyLessonsLimit, monthlyMockExamsUsed: $monthlyMockExamsUsed, monthlyMockExamsLimit: $monthlyMockExamsLimit, lastResetDate: $lastResetDate, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntitlementImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.isPremiumPlus, isPremiumPlus) ||
                other.isPremiumPlus == isPremiumPlus) &&
            (identical(other.dailyVoiceMinutesUsed, dailyVoiceMinutesUsed) ||
                other.dailyVoiceMinutesUsed == dailyVoiceMinutesUsed) &&
            (identical(other.dailyVoiceMinutesLimit, dailyVoiceMinutesLimit) ||
                other.dailyVoiceMinutesLimit == dailyVoiceMinutesLimit) &&
            (identical(other.dailyLessonsUsed, dailyLessonsUsed) ||
                other.dailyLessonsUsed == dailyLessonsUsed) &&
            (identical(other.dailyLessonsLimit, dailyLessonsLimit) ||
                other.dailyLessonsLimit == dailyLessonsLimit) &&
            (identical(other.monthlyMockExamsUsed, monthlyMockExamsUsed) ||
                other.monthlyMockExamsUsed == monthlyMockExamsUsed) &&
            (identical(other.monthlyMockExamsLimit, monthlyMockExamsLimit) ||
                other.monthlyMockExamsLimit == monthlyMockExamsLimit) &&
            (identical(other.lastResetDate, lastResetDate) ||
                other.lastResetDate == lastResetDate) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    isPremium,
    isPremiumPlus,
    dailyVoiceMinutesUsed,
    dailyVoiceMinutesLimit,
    dailyLessonsUsed,
    dailyLessonsLimit,
    monthlyMockExamsUsed,
    monthlyMockExamsLimit,
    lastResetDate,
    updatedAt,
  );

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntitlementImplCopyWith<_$EntitlementImpl> get copyWith =>
      __$$EntitlementImplCopyWithImpl<_$EntitlementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntitlementImplToJson(this);
  }
}

abstract class _Entitlement implements Entitlement {
  const factory _Entitlement({
    required final String userId,
    required final bool isPremium,
    required final bool isPremiumPlus,
    required final int dailyVoiceMinutesUsed,
    required final int dailyVoiceMinutesLimit,
    required final int dailyLessonsUsed,
    required final int dailyLessonsLimit,
    required final int monthlyMockExamsUsed,
    required final int monthlyMockExamsLimit,
    required final DateTime lastResetDate,
    required final DateTime updatedAt,
  }) = _$EntitlementImpl;

  factory _Entitlement.fromJson(Map<String, dynamic> json) =
      _$EntitlementImpl.fromJson;

  @override
  String get userId;
  @override
  bool get isPremium;
  @override
  bool get isPremiumPlus;
  @override
  int get dailyVoiceMinutesUsed;
  @override
  int get dailyVoiceMinutesLimit;
  @override
  int get dailyLessonsUsed;
  @override
  int get dailyLessonsLimit;
  @override
  int get monthlyMockExamsUsed;
  @override
  int get monthlyMockExamsLimit;
  @override
  DateTime get lastResetDate;
  @override
  DateTime get updatedAt;

  /// Create a copy of Entitlement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntitlementImplCopyWith<_$EntitlementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
