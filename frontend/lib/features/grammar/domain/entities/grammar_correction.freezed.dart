// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grammar_correction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GrammarCorrection _$GrammarCorrectionFromJson(Map<String, dynamic> json) {
  return _GrammarCorrection.fromJson(json);
}

/// @nodoc
mixin _$GrammarCorrection {
  String get id => throw _privateConstructorUsedError;
  String get originalText => throw _privateConstructorUsedError;
  String get correctedText => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  String get explanationMalayalam => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  List<String> get suggestions => throw _privateConstructorUsedError;
  List<String> get relatedRules => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  int get startIndex => throw _privateConstructorUsedError;
  int get endIndex => throw _privateConstructorUsedError;

  /// Serializes this GrammarCorrection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrammarCorrection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrammarCorrectionCopyWith<GrammarCorrection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrammarCorrectionCopyWith<$Res> {
  factory $GrammarCorrectionCopyWith(
    GrammarCorrection value,
    $Res Function(GrammarCorrection) then,
  ) = _$GrammarCorrectionCopyWithImpl<$Res, GrammarCorrection>;
  @useResult
  $Res call({
    String id,
    String originalText,
    String correctedText,
    String explanation,
    String explanationMalayalam,
    String category,
    String severity,
    List<String> suggestions,
    List<String> relatedRules,
    DateTime? createdAt,
    int startIndex,
    int endIndex,
  });
}

/// @nodoc
class _$GrammarCorrectionCopyWithImpl<$Res, $Val extends GrammarCorrection>
    implements $GrammarCorrectionCopyWith<$Res> {
  _$GrammarCorrectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrammarCorrection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? correctedText = null,
    Object? explanation = null,
    Object? explanationMalayalam = null,
    Object? category = null,
    Object? severity = null,
    Object? suggestions = null,
    Object? relatedRules = null,
    Object? createdAt = freezed,
    Object? startIndex = null,
    Object? endIndex = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            originalText: null == originalText
                ? _value.originalText
                : originalText // ignore: cast_nullable_to_non_nullable
                      as String,
            correctedText: null == correctedText
                ? _value.correctedText
                : correctedText // ignore: cast_nullable_to_non_nullable
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
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestions: null == suggestions
                ? _value.suggestions
                : suggestions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            relatedRules: null == relatedRules
                ? _value.relatedRules
                : relatedRules // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startIndex: null == startIndex
                ? _value.startIndex
                : startIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            endIndex: null == endIndex
                ? _value.endIndex
                : endIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GrammarCorrectionImplCopyWith<$Res>
    implements $GrammarCorrectionCopyWith<$Res> {
  factory _$$GrammarCorrectionImplCopyWith(
    _$GrammarCorrectionImpl value,
    $Res Function(_$GrammarCorrectionImpl) then,
  ) = __$$GrammarCorrectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String originalText,
    String correctedText,
    String explanation,
    String explanationMalayalam,
    String category,
    String severity,
    List<String> suggestions,
    List<String> relatedRules,
    DateTime? createdAt,
    int startIndex,
    int endIndex,
  });
}

/// @nodoc
class __$$GrammarCorrectionImplCopyWithImpl<$Res>
    extends _$GrammarCorrectionCopyWithImpl<$Res, _$GrammarCorrectionImpl>
    implements _$$GrammarCorrectionImplCopyWith<$Res> {
  __$$GrammarCorrectionImplCopyWithImpl(
    _$GrammarCorrectionImpl _value,
    $Res Function(_$GrammarCorrectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GrammarCorrection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? correctedText = null,
    Object? explanation = null,
    Object? explanationMalayalam = null,
    Object? category = null,
    Object? severity = null,
    Object? suggestions = null,
    Object? relatedRules = null,
    Object? createdAt = freezed,
    Object? startIndex = null,
    Object? endIndex = null,
  }) {
    return _then(
      _$GrammarCorrectionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        originalText: null == originalText
            ? _value.originalText
            : originalText // ignore: cast_nullable_to_non_nullable
                  as String,
        correctedText: null == correctedText
            ? _value.correctedText
            : correctedText // ignore: cast_nullable_to_non_nullable
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
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestions: null == suggestions
            ? _value._suggestions
            : suggestions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        relatedRules: null == relatedRules
            ? _value._relatedRules
            : relatedRules // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startIndex: null == startIndex
            ? _value.startIndex
            : startIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        endIndex: null == endIndex
            ? _value.endIndex
            : endIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GrammarCorrectionImpl implements _GrammarCorrection {
  const _$GrammarCorrectionImpl({
    required this.id,
    required this.originalText,
    required this.correctedText,
    required this.explanation,
    this.explanationMalayalam = '',
    this.category = '',
    this.severity = 'medium',
    final List<String> suggestions = const [],
    final List<String> relatedRules = const [],
    this.createdAt,
    this.startIndex = 0,
    this.endIndex = 0,
  }) : _suggestions = suggestions,
       _relatedRules = relatedRules;

  factory _$GrammarCorrectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrammarCorrectionImplFromJson(json);

  @override
  final String id;
  @override
  final String originalText;
  @override
  final String correctedText;
  @override
  final String explanation;
  @override
  @JsonKey()
  final String explanationMalayalam;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final String severity;
  final List<String> _suggestions;
  @override
  @JsonKey()
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  final List<String> _relatedRules;
  @override
  @JsonKey()
  List<String> get relatedRules {
    if (_relatedRules is EqualUnmodifiableListView) return _relatedRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_relatedRules);
  }

  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final int startIndex;
  @override
  @JsonKey()
  final int endIndex;

  @override
  String toString() {
    return 'GrammarCorrection(id: $id, originalText: $originalText, correctedText: $correctedText, explanation: $explanation, explanationMalayalam: $explanationMalayalam, category: $category, severity: $severity, suggestions: $suggestions, relatedRules: $relatedRules, createdAt: $createdAt, startIndex: $startIndex, endIndex: $endIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrammarCorrectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalText, originalText) ||
                other.originalText == originalText) &&
            (identical(other.correctedText, correctedText) ||
                other.correctedText == correctedText) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.explanationMalayalam, explanationMalayalam) ||
                other.explanationMalayalam == explanationMalayalam) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality().equals(
              other._suggestions,
              _suggestions,
            ) &&
            const DeepCollectionEquality().equals(
              other._relatedRules,
              _relatedRules,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.endIndex, endIndex) ||
                other.endIndex == endIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    originalText,
    correctedText,
    explanation,
    explanationMalayalam,
    category,
    severity,
    const DeepCollectionEquality().hash(_suggestions),
    const DeepCollectionEquality().hash(_relatedRules),
    createdAt,
    startIndex,
    endIndex,
  );

  /// Create a copy of GrammarCorrection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrammarCorrectionImplCopyWith<_$GrammarCorrectionImpl> get copyWith =>
      __$$GrammarCorrectionImplCopyWithImpl<_$GrammarCorrectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GrammarCorrectionImplToJson(this);
  }
}

abstract class _GrammarCorrection implements GrammarCorrection {
  const factory _GrammarCorrection({
    required final String id,
    required final String originalText,
    required final String correctedText,
    required final String explanation,
    final String explanationMalayalam,
    final String category,
    final String severity,
    final List<String> suggestions,
    final List<String> relatedRules,
    final DateTime? createdAt,
    final int startIndex,
    final int endIndex,
  }) = _$GrammarCorrectionImpl;

  factory _GrammarCorrection.fromJson(Map<String, dynamic> json) =
      _$GrammarCorrectionImpl.fromJson;

  @override
  String get id;
  @override
  String get originalText;
  @override
  String get correctedText;
  @override
  String get explanation;
  @override
  String get explanationMalayalam;
  @override
  String get category;
  @override
  String get severity;
  @override
  List<String> get suggestions;
  @override
  List<String> get relatedRules;
  @override
  DateTime? get createdAt;
  @override
  int get startIndex;
  @override
  int get endIndex;

  /// Create a copy of GrammarCorrection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrammarCorrectionImplCopyWith<_$GrammarCorrectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
