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

GrammarFeedback _$GrammarFeedbackFromJson(Map<String, dynamic> json) {
  return _GrammarFeedback.fromJson(json);
}

/// @nodoc
mixin _$GrammarFeedback {
  bool get isCorrect => throw _privateConstructorUsedError;
  String get original => throw _privateConstructorUsedError;
  String get corrected => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  String get explanationMalayalam => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<String> get examples => throw _privateConstructorUsedError;

  /// Serializes this GrammarFeedback to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrammarFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrammarFeedbackCopyWith<GrammarFeedback> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrammarFeedbackCopyWith<$Res> {
  factory $GrammarFeedbackCopyWith(
    GrammarFeedback value,
    $Res Function(GrammarFeedback) then,
  ) = _$GrammarFeedbackCopyWithImpl<$Res, GrammarFeedback>;
  @useResult
  $Res call({
    bool isCorrect,
    String original,
    String corrected,
    String explanation,
    String explanationMalayalam,
    String category,
    List<String> examples,
  });
}

/// @nodoc
class _$GrammarFeedbackCopyWithImpl<$Res, $Val extends GrammarFeedback>
    implements $GrammarFeedbackCopyWith<$Res> {
  _$GrammarFeedbackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrammarFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCorrect = null,
    Object? original = null,
    Object? corrected = null,
    Object? explanation = null,
    Object? explanationMalayalam = null,
    Object? category = null,
    Object? examples = null,
  }) {
    return _then(
      _value.copyWith(
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            original: null == original
                ? _value.original
                : original // ignore: cast_nullable_to_non_nullable
                      as String,
            corrected: null == corrected
                ? _value.corrected
                : corrected // ignore: cast_nullable_to_non_nullable
                      as String,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
            explanationMalayalam: null == explanationMalayalam
                ? _value.explanationMalayalam
                : explanationMalayalam // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            examples: null == examples
                ? _value.examples
                : examples // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GrammarFeedbackImplCopyWith<$Res>
    implements $GrammarFeedbackCopyWith<$Res> {
  factory _$$GrammarFeedbackImplCopyWith(
    _$GrammarFeedbackImpl value,
    $Res Function(_$GrammarFeedbackImpl) then,
  ) = __$$GrammarFeedbackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isCorrect,
    String original,
    String corrected,
    String explanation,
    String explanationMalayalam,
    String category,
    List<String> examples,
  });
}

/// @nodoc
class __$$GrammarFeedbackImplCopyWithImpl<$Res>
    extends _$GrammarFeedbackCopyWithImpl<$Res, _$GrammarFeedbackImpl>
    implements _$$GrammarFeedbackImplCopyWith<$Res> {
  __$$GrammarFeedbackImplCopyWithImpl(
    _$GrammarFeedbackImpl _value,
    $Res Function(_$GrammarFeedbackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GrammarFeedback
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCorrect = null,
    Object? original = null,
    Object? corrected = null,
    Object? explanation = null,
    Object? explanationMalayalam = null,
    Object? category = null,
    Object? examples = null,
  }) {
    return _then(
      _$GrammarFeedbackImpl(
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        original: null == original
            ? _value.original
            : original // ignore: cast_nullable_to_non_nullable
                  as String,
        corrected: null == corrected
            ? _value.corrected
            : corrected // ignore: cast_nullable_to_non_nullable
                  as String,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
        explanationMalayalam: null == explanationMalayalam
            ? _value.explanationMalayalam
            : explanationMalayalam // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        examples: null == examples
            ? _value._examples
            : examples // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GrammarFeedbackImpl implements _GrammarFeedback {
  const _$GrammarFeedbackImpl({
    this.isCorrect = false,
    required this.original,
    required this.corrected,
    required this.explanation,
    this.explanationMalayalam = '',
    this.category = '',
    final List<String> examples = const [],
  }) : _examples = examples;

  factory _$GrammarFeedbackImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrammarFeedbackImplFromJson(json);

  @override
  @JsonKey()
  final bool isCorrect;
  @override
  final String original;
  @override
  final String corrected;
  @override
  final String explanation;
  @override
  @JsonKey()
  final String explanationMalayalam;
  @override
  @JsonKey()
  final String category;
  final List<String> _examples;
  @override
  @JsonKey()
  List<String> get examples {
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examples);
  }

  @override
  String toString() {
    return 'GrammarFeedback(isCorrect: $isCorrect, original: $original, corrected: $corrected, explanation: $explanation, explanationMalayalam: $explanationMalayalam, category: $category, examples: $examples)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrammarFeedbackImpl &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.original, original) ||
                other.original == original) &&
            (identical(other.corrected, corrected) ||
                other.corrected == corrected) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.explanationMalayalam, explanationMalayalam) ||
                other.explanationMalayalam == explanationMalayalam) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._examples, _examples));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isCorrect,
    original,
    corrected,
    explanation,
    explanationMalayalam,
    category,
    const DeepCollectionEquality().hash(_examples),
  );

  /// Create a copy of GrammarFeedback
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrammarFeedbackImplCopyWith<_$GrammarFeedbackImpl> get copyWith =>
      __$$GrammarFeedbackImplCopyWithImpl<_$GrammarFeedbackImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GrammarFeedbackImplToJson(this);
  }
}

abstract class _GrammarFeedback implements GrammarFeedback {
  const factory _GrammarFeedback({
    final bool isCorrect,
    required final String original,
    required final String corrected,
    required final String explanation,
    final String explanationMalayalam,
    final String category,
    final List<String> examples,
  }) = _$GrammarFeedbackImpl;

  factory _GrammarFeedback.fromJson(Map<String, dynamic> json) =
      _$GrammarFeedbackImpl.fromJson;

  @override
  bool get isCorrect;
  @override
  String get original;
  @override
  String get corrected;
  @override
  String get explanation;
  @override
  String get explanationMalayalam;
  @override
  String get category;
  @override
  List<String> get examples;

  /// Create a copy of GrammarFeedback
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrammarFeedbackImplCopyWith<_$GrammarFeedbackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TranslationData _$TranslationDataFromJson(Map<String, dynamic> json) {
  return _TranslationData.fromJson(json);
}

/// @nodoc
mixin _$TranslationData {
  String get translation => throw _privateConstructorUsedError;
  String get pronunciation => throw _privateConstructorUsedError;
  Map<String, String>? get alternativeExpressions =>
      throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  /// Serializes this TranslationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranslationDataCopyWith<TranslationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationDataCopyWith<$Res> {
  factory $TranslationDataCopyWith(
    TranslationData value,
    $Res Function(TranslationData) then,
  ) = _$TranslationDataCopyWithImpl<$Res, TranslationData>;
  @useResult
  $Res call({
    String translation,
    String pronunciation,
    Map<String, String>? alternativeExpressions,
    String explanation,
  });
}

/// @nodoc
class _$TranslationDataCopyWithImpl<$Res, $Val extends TranslationData>
    implements $TranslationDataCopyWith<$Res> {
  _$TranslationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translation = null,
    Object? pronunciation = null,
    Object? alternativeExpressions = freezed,
    Object? explanation = null,
  }) {
    return _then(
      _value.copyWith(
            translation: null == translation
                ? _value.translation
                : translation // ignore: cast_nullable_to_non_nullable
                      as String,
            pronunciation: null == pronunciation
                ? _value.pronunciation
                : pronunciation // ignore: cast_nullable_to_non_nullable
                      as String,
            alternativeExpressions: freezed == alternativeExpressions
                ? _value.alternativeExpressions
                : alternativeExpressions // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            explanation: null == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranslationDataImplCopyWith<$Res>
    implements $TranslationDataCopyWith<$Res> {
  factory _$$TranslationDataImplCopyWith(
    _$TranslationDataImpl value,
    $Res Function(_$TranslationDataImpl) then,
  ) = __$$TranslationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String translation,
    String pronunciation,
    Map<String, String>? alternativeExpressions,
    String explanation,
  });
}

/// @nodoc
class __$$TranslationDataImplCopyWithImpl<$Res>
    extends _$TranslationDataCopyWithImpl<$Res, _$TranslationDataImpl>
    implements _$$TranslationDataImplCopyWith<$Res> {
  __$$TranslationDataImplCopyWithImpl(
    _$TranslationDataImpl _value,
    $Res Function(_$TranslationDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? translation = null,
    Object? pronunciation = null,
    Object? alternativeExpressions = freezed,
    Object? explanation = null,
  }) {
    return _then(
      _$TranslationDataImpl(
        translation: null == translation
            ? _value.translation
            : translation // ignore: cast_nullable_to_non_nullable
                  as String,
        pronunciation: null == pronunciation
            ? _value.pronunciation
            : pronunciation // ignore: cast_nullable_to_non_nullable
                  as String,
        alternativeExpressions: freezed == alternativeExpressions
            ? _value._alternativeExpressions
            : alternativeExpressions // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        explanation: null == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranslationDataImpl implements _TranslationData {
  const _$TranslationDataImpl({
    required this.translation,
    this.pronunciation = '',
    final Map<String, String>? alternativeExpressions,
    this.explanation = '',
  }) : _alternativeExpressions = alternativeExpressions;

  factory _$TranslationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranslationDataImplFromJson(json);

  @override
  final String translation;
  @override
  @JsonKey()
  final String pronunciation;
  final Map<String, String>? _alternativeExpressions;
  @override
  Map<String, String>? get alternativeExpressions {
    final value = _alternativeExpressions;
    if (value == null) return null;
    if (_alternativeExpressions is EqualUnmodifiableMapView)
      return _alternativeExpressions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String explanation;

  @override
  String toString() {
    return 'TranslationData(translation: $translation, pronunciation: $pronunciation, alternativeExpressions: $alternativeExpressions, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationDataImpl &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.pronunciation, pronunciation) ||
                other.pronunciation == pronunciation) &&
            const DeepCollectionEquality().equals(
              other._alternativeExpressions,
              _alternativeExpressions,
            ) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    translation,
    pronunciation,
    const DeepCollectionEquality().hash(_alternativeExpressions),
    explanation,
  );

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationDataImplCopyWith<_$TranslationDataImpl> get copyWith =>
      __$$TranslationDataImplCopyWithImpl<_$TranslationDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TranslationDataImplToJson(this);
  }
}

abstract class _TranslationData implements TranslationData {
  const factory _TranslationData({
    required final String translation,
    final String pronunciation,
    final Map<String, String>? alternativeExpressions,
    final String explanation,
  }) = _$TranslationDataImpl;

  factory _TranslationData.fromJson(Map<String, dynamic> json) =
      _$TranslationDataImpl.fromJson;

  @override
  String get translation;
  @override
  String get pronunciation;
  @override
  Map<String, String>? get alternativeExpressions;
  @override
  String get explanation;

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslationDataImplCopyWith<_$TranslationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
