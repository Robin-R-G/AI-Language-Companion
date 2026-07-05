// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocabulary_word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VocabularyWord _$VocabularyWordFromJson(Map<String, dynamic> json) {
  return _VocabularyWord.fromJson(json);
}

/// @nodoc
mixin _$VocabularyWord {
  String get id => throw _privateConstructorUsedError;
  String get word => throw _privateConstructorUsedError;
  String get meaning => throw _privateConstructorUsedError;
  String get pronunciation => throw _privateConstructorUsedError;
  List<String> get examples => throw _privateConstructorUsedError;
  String get cefrLevel => throw _privateConstructorUsedError;
  String get partOfSpeech => throw _privateConstructorUsedError;
  String get targetLanguage => throw _privateConstructorUsedError;
  String get nativeLanguage => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VocabularyWord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VocabularyWord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VocabularyWordCopyWith<VocabularyWord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabularyWordCopyWith<$Res> {
  factory $VocabularyWordCopyWith(
    VocabularyWord value,
    $Res Function(VocabularyWord) then,
  ) = _$VocabularyWordCopyWithImpl<$Res, VocabularyWord>;
  @useResult
  $Res call({
    String id,
    String word,
    String meaning,
    String pronunciation,
    List<String> examples,
    String cefrLevel,
    String partOfSpeech,
    String targetLanguage,
    String nativeLanguage,
    String? audioUrl,
    String? imageUrl,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VocabularyWordCopyWithImpl<$Res, $Val extends VocabularyWord>
    implements $VocabularyWordCopyWith<$Res> {
  _$VocabularyWordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VocabularyWord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? word = null,
    Object? meaning = null,
    Object? pronunciation = null,
    Object? examples = null,
    Object? cefrLevel = null,
    Object? partOfSpeech = null,
    Object? targetLanguage = null,
    Object? nativeLanguage = null,
    Object? audioUrl = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            word: null == word
                ? _value.word
                : word // ignore: cast_nullable_to_non_nullable
                      as String,
            meaning: null == meaning
                ? _value.meaning
                : meaning // ignore: cast_nullable_to_non_nullable
                      as String,
            pronunciation: null == pronunciation
                ? _value.pronunciation
                : pronunciation // ignore: cast_nullable_to_non_nullable
                      as String,
            examples: null == examples
                ? _value.examples
                : examples // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            cefrLevel: null == cefrLevel
                ? _value.cefrLevel
                : cefrLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            partOfSpeech: null == partOfSpeech
                ? _value.partOfSpeech
                : partOfSpeech // ignore: cast_nullable_to_non_nullable
                      as String,
            targetLanguage: null == targetLanguage
                ? _value.targetLanguage
                : targetLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            nativeLanguage: null == nativeLanguage
                ? _value.nativeLanguage
                : nativeLanguage // ignore: cast_nullable_to_non_nullable
                      as String,
            audioUrl: freezed == audioUrl
                ? _value.audioUrl
                : audioUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$VocabularyWordImplCopyWith<$Res>
    implements $VocabularyWordCopyWith<$Res> {
  factory _$$VocabularyWordImplCopyWith(
    _$VocabularyWordImpl value,
    $Res Function(_$VocabularyWordImpl) then,
  ) = __$$VocabularyWordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String word,
    String meaning,
    String pronunciation,
    List<String> examples,
    String cefrLevel,
    String partOfSpeech,
    String targetLanguage,
    String nativeLanguage,
    String? audioUrl,
    String? imageUrl,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VocabularyWordImplCopyWithImpl<$Res>
    extends _$VocabularyWordCopyWithImpl<$Res, _$VocabularyWordImpl>
    implements _$$VocabularyWordImplCopyWith<$Res> {
  __$$VocabularyWordImplCopyWithImpl(
    _$VocabularyWordImpl _value,
    $Res Function(_$VocabularyWordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VocabularyWord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? word = null,
    Object? meaning = null,
    Object? pronunciation = null,
    Object? examples = null,
    Object? cefrLevel = null,
    Object? partOfSpeech = null,
    Object? targetLanguage = null,
    Object? nativeLanguage = null,
    Object? audioUrl = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$VocabularyWordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        word: null == word
            ? _value.word
            : word // ignore: cast_nullable_to_non_nullable
                  as String,
        meaning: null == meaning
            ? _value.meaning
            : meaning // ignore: cast_nullable_to_non_nullable
                  as String,
        pronunciation: null == pronunciation
            ? _value.pronunciation
            : pronunciation // ignore: cast_nullable_to_non_nullable
                  as String,
        examples: null == examples
            ? _value._examples
            : examples // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        cefrLevel: null == cefrLevel
            ? _value.cefrLevel
            : cefrLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        partOfSpeech: null == partOfSpeech
            ? _value.partOfSpeech
            : partOfSpeech // ignore: cast_nullable_to_non_nullable
                  as String,
        targetLanguage: null == targetLanguage
            ? _value.targetLanguage
            : targetLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        nativeLanguage: null == nativeLanguage
            ? _value.nativeLanguage
            : nativeLanguage // ignore: cast_nullable_to_non_nullable
                  as String,
        audioUrl: freezed == audioUrl
            ? _value.audioUrl
            : audioUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$VocabularyWordImpl implements _VocabularyWord {
  const _$VocabularyWordImpl({
    required this.id,
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required final List<String> examples,
    required this.cefrLevel,
    required this.partOfSpeech,
    required this.targetLanguage,
    required this.nativeLanguage,
    required this.audioUrl,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : _examples = examples;

  factory _$VocabularyWordImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabularyWordImplFromJson(json);

  @override
  final String id;
  @override
  final String word;
  @override
  final String meaning;
  @override
  final String pronunciation;
  final List<String> _examples;
  @override
  List<String> get examples {
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examples);
  }

  @override
  final String cefrLevel;
  @override
  final String partOfSpeech;
  @override
  final String targetLanguage;
  @override
  final String nativeLanguage;
  @override
  final String? audioUrl;
  @override
  final String? imageUrl;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VocabularyWord(id: $id, word: $word, meaning: $meaning, pronunciation: $pronunciation, examples: $examples, cefrLevel: $cefrLevel, partOfSpeech: $partOfSpeech, targetLanguage: $targetLanguage, nativeLanguage: $nativeLanguage, audioUrl: $audioUrl, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabularyWordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.pronunciation, pronunciation) ||
                other.pronunciation == pronunciation) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            (identical(other.cefrLevel, cefrLevel) ||
                other.cefrLevel == cefrLevel) &&
            (identical(other.partOfSpeech, partOfSpeech) ||
                other.partOfSpeech == partOfSpeech) &&
            (identical(other.targetLanguage, targetLanguage) ||
                other.targetLanguage == targetLanguage) &&
            (identical(other.nativeLanguage, nativeLanguage) ||
                other.nativeLanguage == nativeLanguage) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
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
    word,
    meaning,
    pronunciation,
    const DeepCollectionEquality().hash(_examples),
    cefrLevel,
    partOfSpeech,
    targetLanguage,
    nativeLanguage,
    audioUrl,
    imageUrl,
    createdAt,
    updatedAt,
  );

  /// Create a copy of VocabularyWord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabularyWordImplCopyWith<_$VocabularyWordImpl> get copyWith =>
      __$$VocabularyWordImplCopyWithImpl<_$VocabularyWordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabularyWordImplToJson(this);
  }
}

abstract class _VocabularyWord implements VocabularyWord {
  const factory _VocabularyWord({
    required final String id,
    required final String word,
    required final String meaning,
    required final String pronunciation,
    required final List<String> examples,
    required final String cefrLevel,
    required final String partOfSpeech,
    required final String targetLanguage,
    required final String nativeLanguage,
    required final String? audioUrl,
    required final String? imageUrl,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VocabularyWordImpl;

  factory _VocabularyWord.fromJson(Map<String, dynamic> json) =
      _$VocabularyWordImpl.fromJson;

  @override
  String get id;
  @override
  String get word;
  @override
  String get meaning;
  @override
  String get pronunciation;
  @override
  List<String> get examples;
  @override
  String get cefrLevel;
  @override
  String get partOfSpeech;
  @override
  String get targetLanguage;
  @override
  String get nativeLanguage;
  @override
  String? get audioUrl;
  @override
  String? get imageUrl;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of VocabularyWord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VocabularyWordImplCopyWith<_$VocabularyWordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VocabularyProgress _$VocabularyProgressFromJson(Map<String, dynamic> json) {
  return _VocabularyProgress.fromJson(json);
}

/// @nodoc
mixin _$VocabularyProgress {
  String get userId => throw _privateConstructorUsedError;
  String get vocabularyId => throw _privateConstructorUsedError;
  int get masteryLevel => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  DateTime get nextReview => throw _privateConstructorUsedError;
  DateTime get lastReviewed => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VocabularyProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VocabularyProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VocabularyProgressCopyWith<VocabularyProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabularyProgressCopyWith<$Res> {
  factory $VocabularyProgressCopyWith(
    VocabularyProgress value,
    $Res Function(VocabularyProgress) then,
  ) = _$VocabularyProgressCopyWithImpl<$Res, VocabularyProgress>;
  @useResult
  $Res call({
    String userId,
    String vocabularyId,
    int masteryLevel,
    int reviewCount,
    DateTime nextReview,
    DateTime lastReviewed,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VocabularyProgressCopyWithImpl<$Res, $Val extends VocabularyProgress>
    implements $VocabularyProgressCopyWith<$Res> {
  _$VocabularyProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VocabularyProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? vocabularyId = null,
    Object? masteryLevel = null,
    Object? reviewCount = null,
    Object? nextReview = null,
    Object? lastReviewed = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            vocabularyId: null == vocabularyId
                ? _value.vocabularyId
                : vocabularyId // ignore: cast_nullable_to_non_nullable
                      as String,
            masteryLevel: null == masteryLevel
                ? _value.masteryLevel
                : masteryLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            nextReview: null == nextReview
                ? _value.nextReview
                : nextReview // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastReviewed: null == lastReviewed
                ? _value.lastReviewed
                : lastReviewed // ignore: cast_nullable_to_non_nullable
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
abstract class _$$VocabularyProgressImplCopyWith<$Res>
    implements $VocabularyProgressCopyWith<$Res> {
  factory _$$VocabularyProgressImplCopyWith(
    _$VocabularyProgressImpl value,
    $Res Function(_$VocabularyProgressImpl) then,
  ) = __$$VocabularyProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String vocabularyId,
    int masteryLevel,
    int reviewCount,
    DateTime nextReview,
    DateTime lastReviewed,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VocabularyProgressImplCopyWithImpl<$Res>
    extends _$VocabularyProgressCopyWithImpl<$Res, _$VocabularyProgressImpl>
    implements _$$VocabularyProgressImplCopyWith<$Res> {
  __$$VocabularyProgressImplCopyWithImpl(
    _$VocabularyProgressImpl _value,
    $Res Function(_$VocabularyProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VocabularyProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? vocabularyId = null,
    Object? masteryLevel = null,
    Object? reviewCount = null,
    Object? nextReview = null,
    Object? lastReviewed = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$VocabularyProgressImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        vocabularyId: null == vocabularyId
            ? _value.vocabularyId
            : vocabularyId // ignore: cast_nullable_to_non_nullable
                  as String,
        masteryLevel: null == masteryLevel
            ? _value.masteryLevel
            : masteryLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        nextReview: null == nextReview
            ? _value.nextReview
            : nextReview // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastReviewed: null == lastReviewed
            ? _value.lastReviewed
            : lastReviewed // ignore: cast_nullable_to_non_nullable
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
class _$VocabularyProgressImpl implements _VocabularyProgress {
  const _$VocabularyProgressImpl({
    required this.userId,
    required this.vocabularyId,
    required this.masteryLevel,
    required this.reviewCount,
    required this.nextReview,
    required this.lastReviewed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$VocabularyProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabularyProgressImplFromJson(json);

  @override
  final String userId;
  @override
  final String vocabularyId;
  @override
  final int masteryLevel;
  @override
  final int reviewCount;
  @override
  final DateTime nextReview;
  @override
  final DateTime lastReviewed;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VocabularyProgress(userId: $userId, vocabularyId: $vocabularyId, masteryLevel: $masteryLevel, reviewCount: $reviewCount, nextReview: $nextReview, lastReviewed: $lastReviewed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabularyProgressImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.vocabularyId, vocabularyId) ||
                other.vocabularyId == vocabularyId) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.nextReview, nextReview) ||
                other.nextReview == nextReview) &&
            (identical(other.lastReviewed, lastReviewed) ||
                other.lastReviewed == lastReviewed) &&
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
    vocabularyId,
    masteryLevel,
    reviewCount,
    nextReview,
    lastReviewed,
    createdAt,
    updatedAt,
  );

  /// Create a copy of VocabularyProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabularyProgressImplCopyWith<_$VocabularyProgressImpl> get copyWith =>
      __$$VocabularyProgressImplCopyWithImpl<_$VocabularyProgressImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabularyProgressImplToJson(this);
  }
}

abstract class _VocabularyProgress implements VocabularyProgress {
  const factory _VocabularyProgress({
    required final String userId,
    required final String vocabularyId,
    required final int masteryLevel,
    required final int reviewCount,
    required final DateTime nextReview,
    required final DateTime lastReviewed,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VocabularyProgressImpl;

  factory _VocabularyProgress.fromJson(Map<String, dynamic> json) =
      _$VocabularyProgressImpl.fromJson;

  @override
  String get userId;
  @override
  String get vocabularyId;
  @override
  int get masteryLevel;
  @override
  int get reviewCount;
  @override
  DateTime get nextReview;
  @override
  DateTime get lastReviewed;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of VocabularyProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VocabularyProgressImplCopyWith<_$VocabularyProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
