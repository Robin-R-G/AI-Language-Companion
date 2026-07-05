// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return _Lesson.fromJson(json);
}

/// @nodoc
mixin _$Lesson {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  int get estimatedMinutes => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  List<LessonQuiz>? get quizzes => throw _privateConstructorUsedError;
  List<LessonVocabulary>? get vocabulary => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonCopyWith<Lesson> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) then) =
      _$LessonCopyWithImpl<$Res, Lesson>;
  @useResult
  $Res call({
    String id,
    String title,
    String category,
    String difficulty,
    String language,
    int estimatedMinutes,
    String? content,
    List<LessonQuiz>? quizzes,
    List<LessonVocabulary>? vocabulary,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$LessonCopyWithImpl<$Res, $Val extends Lesson>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = null,
    Object? difficulty = null,
    Object? language = null,
    Object? estimatedMinutes = null,
    Object? content = freezed,
    Object? quizzes = freezed,
    Object? vocabulary = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            language: null == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedMinutes: null == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            quizzes: freezed == quizzes
                ? _value.quizzes
                : quizzes // ignore: cast_nullable_to_non_nullable
                      as List<LessonQuiz>?,
            vocabulary: freezed == vocabulary
                ? _value.vocabulary
                : vocabulary // ignore: cast_nullable_to_non_nullable
                      as List<LessonVocabulary>?,
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
abstract class _$$LessonImplCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$$LessonImplCopyWith(
    _$LessonImpl value,
    $Res Function(_$LessonImpl) then,
  ) = __$$LessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String category,
    String difficulty,
    String language,
    int estimatedMinutes,
    String? content,
    List<LessonQuiz>? quizzes,
    List<LessonVocabulary>? vocabulary,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$LessonImplCopyWithImpl<$Res>
    extends _$LessonCopyWithImpl<$Res, _$LessonImpl>
    implements _$$LessonImplCopyWith<$Res> {
  __$$LessonImplCopyWithImpl(
    _$LessonImpl _value,
    $Res Function(_$LessonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = null,
    Object? difficulty = null,
    Object? language = null,
    Object? estimatedMinutes = null,
    Object? content = freezed,
    Object? quizzes = freezed,
    Object? vocabulary = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$LessonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        language: null == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedMinutes: null == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        quizzes: freezed == quizzes
            ? _value._quizzes
            : quizzes // ignore: cast_nullable_to_non_nullable
                  as List<LessonQuiz>?,
        vocabulary: freezed == vocabulary
            ? _value._vocabulary
            : vocabulary // ignore: cast_nullable_to_non_nullable
                  as List<LessonVocabulary>?,
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
class _$LessonImpl implements _Lesson {
  const _$LessonImpl({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.language,
    required this.estimatedMinutes,
    this.content,
    final List<LessonQuiz>? quizzes,
    final List<LessonVocabulary>? vocabulary,
    this.createdAt,
  }) : _quizzes = quizzes,
       _vocabulary = vocabulary;

  factory _$LessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String category;
  @override
  final String difficulty;
  @override
  final String language;
  @override
  final int estimatedMinutes;
  @override
  final String? content;
  final List<LessonQuiz>? _quizzes;
  @override
  List<LessonQuiz>? get quizzes {
    final value = _quizzes;
    if (value == null) return null;
    if (_quizzes is EqualUnmodifiableListView) return _quizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<LessonVocabulary>? _vocabulary;
  @override
  List<LessonVocabulary>? get vocabulary {
    final value = _vocabulary;
    if (value == null) return null;
    if (_vocabulary is EqualUnmodifiableListView) return _vocabulary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, category: $category, difficulty: $difficulty, language: $language, estimatedMinutes: $estimatedMinutes, content: $content, quizzes: $quizzes, vocabulary: $vocabulary, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._quizzes, _quizzes) &&
            const DeepCollectionEquality().equals(
              other._vocabulary,
              _vocabulary,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    category,
    difficulty,
    language,
    estimatedMinutes,
    content,
    const DeepCollectionEquality().hash(_quizzes),
    const DeepCollectionEquality().hash(_vocabulary),
    createdAt,
  );

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      __$$LessonImplCopyWithImpl<_$LessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonImplToJson(this);
  }
}

abstract class _Lesson implements Lesson {
  const factory _Lesson({
    required final String id,
    required final String title,
    required final String category,
    required final String difficulty,
    required final String language,
    required final int estimatedMinutes,
    final String? content,
    final List<LessonQuiz>? quizzes,
    final List<LessonVocabulary>? vocabulary,
    final DateTime? createdAt,
  }) = _$LessonImpl;

  factory _Lesson.fromJson(Map<String, dynamic> json) = _$LessonImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get category;
  @override
  String get difficulty;
  @override
  String get language;
  @override
  int get estimatedMinutes;
  @override
  String? get content;
  @override
  List<LessonQuiz>? get quizzes;
  @override
  List<LessonVocabulary>? get vocabulary;
  @override
  DateTime? get createdAt;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonQuiz _$LessonQuizFromJson(Map<String, dynamic> json) {
  return _LessonQuiz.fromJson(json);
}

/// @nodoc
mixin _$LessonQuiz {
  String get questionId => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int get correctOptionIndex => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;

  /// Serializes this LessonQuiz to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonQuiz
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonQuizCopyWith<LessonQuiz> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonQuizCopyWith<$Res> {
  factory $LessonQuizCopyWith(
    LessonQuiz value,
    $Res Function(LessonQuiz) then,
  ) = _$LessonQuizCopyWithImpl<$Res, LessonQuiz>;
  @useResult
  $Res call({
    String questionId,
    String question,
    List<String> options,
    int correctOptionIndex,
    String? explanation,
  });
}

/// @nodoc
class _$LessonQuizCopyWithImpl<$Res, $Val extends LessonQuiz>
    implements $LessonQuizCopyWith<$Res> {
  _$LessonQuizCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonQuiz
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? question = null,
    Object? options = null,
    Object? correctOptionIndex = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _value.copyWith(
            questionId: null == questionId
                ? _value.questionId
                : questionId // ignore: cast_nullable_to_non_nullable
                      as String,
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctOptionIndex: null == correctOptionIndex
                ? _value.correctOptionIndex
                : correctOptionIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonQuizImplCopyWith<$Res>
    implements $LessonQuizCopyWith<$Res> {
  factory _$$LessonQuizImplCopyWith(
    _$LessonQuizImpl value,
    $Res Function(_$LessonQuizImpl) then,
  ) = __$$LessonQuizImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String questionId,
    String question,
    List<String> options,
    int correctOptionIndex,
    String? explanation,
  });
}

/// @nodoc
class __$$LessonQuizImplCopyWithImpl<$Res>
    extends _$LessonQuizCopyWithImpl<$Res, _$LessonQuizImpl>
    implements _$$LessonQuizImplCopyWith<$Res> {
  __$$LessonQuizImplCopyWithImpl(
    _$LessonQuizImpl _value,
    $Res Function(_$LessonQuizImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonQuiz
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? question = null,
    Object? options = null,
    Object? correctOptionIndex = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _$LessonQuizImpl(
        questionId: null == questionId
            ? _value.questionId
            : questionId // ignore: cast_nullable_to_non_nullable
                  as String,
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctOptionIndex: null == correctOptionIndex
            ? _value.correctOptionIndex
            : correctOptionIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonQuizImpl implements _LessonQuiz {
  const _$LessonQuizImpl({
    required this.questionId,
    required this.question,
    required final List<String> options,
    required this.correctOptionIndex,
    this.explanation,
  }) : _options = options;

  factory _$LessonQuizImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonQuizImplFromJson(json);

  @override
  final String questionId;
  @override
  final String question;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctOptionIndex;
  @override
  final String? explanation;

  @override
  String toString() {
    return 'LessonQuiz(questionId: $questionId, question: $question, options: $options, correctOptionIndex: $correctOptionIndex, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonQuizImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctOptionIndex, correctOptionIndex) ||
                other.correctOptionIndex == correctOptionIndex) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    questionId,
    question,
    const DeepCollectionEquality().hash(_options),
    correctOptionIndex,
    explanation,
  );

  /// Create a copy of LessonQuiz
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonQuizImplCopyWith<_$LessonQuizImpl> get copyWith =>
      __$$LessonQuizImplCopyWithImpl<_$LessonQuizImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonQuizImplToJson(this);
  }
}

abstract class _LessonQuiz implements LessonQuiz {
  const factory _LessonQuiz({
    required final String questionId,
    required final String question,
    required final List<String> options,
    required final int correctOptionIndex,
    final String? explanation,
  }) = _$LessonQuizImpl;

  factory _LessonQuiz.fromJson(Map<String, dynamic> json) =
      _$LessonQuizImpl.fromJson;

  @override
  String get questionId;
  @override
  String get question;
  @override
  List<String> get options;
  @override
  int get correctOptionIndex;
  @override
  String? get explanation;

  /// Create a copy of LessonQuiz
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonQuizImplCopyWith<_$LessonQuizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonVocabulary _$LessonVocabularyFromJson(Map<String, dynamic> json) {
  return _LessonVocabulary.fromJson(json);
}

/// @nodoc
mixin _$LessonVocabulary {
  String get word => throw _privateConstructorUsedError;
  String get definition => throw _privateConstructorUsedError;
  String? get example => throw _privateConstructorUsedError;

  /// Serializes this LessonVocabulary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonVocabulary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonVocabularyCopyWith<LessonVocabulary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonVocabularyCopyWith<$Res> {
  factory $LessonVocabularyCopyWith(
    LessonVocabulary value,
    $Res Function(LessonVocabulary) then,
  ) = _$LessonVocabularyCopyWithImpl<$Res, LessonVocabulary>;
  @useResult
  $Res call({String word, String definition, String? example});
}

/// @nodoc
class _$LessonVocabularyCopyWithImpl<$Res, $Val extends LessonVocabulary>
    implements $LessonVocabularyCopyWith<$Res> {
  _$LessonVocabularyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonVocabulary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? definition = null,
    Object? example = freezed,
  }) {
    return _then(
      _value.copyWith(
            word: null == word
                ? _value.word
                : word // ignore: cast_nullable_to_non_nullable
                      as String,
            definition: null == definition
                ? _value.definition
                : definition // ignore: cast_nullable_to_non_nullable
                      as String,
            example: freezed == example
                ? _value.example
                : example // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonVocabularyImplCopyWith<$Res>
    implements $LessonVocabularyCopyWith<$Res> {
  factory _$$LessonVocabularyImplCopyWith(
    _$LessonVocabularyImpl value,
    $Res Function(_$LessonVocabularyImpl) then,
  ) = __$$LessonVocabularyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String word, String definition, String? example});
}

/// @nodoc
class __$$LessonVocabularyImplCopyWithImpl<$Res>
    extends _$LessonVocabularyCopyWithImpl<$Res, _$LessonVocabularyImpl>
    implements _$$LessonVocabularyImplCopyWith<$Res> {
  __$$LessonVocabularyImplCopyWithImpl(
    _$LessonVocabularyImpl _value,
    $Res Function(_$LessonVocabularyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonVocabulary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? definition = null,
    Object? example = freezed,
  }) {
    return _then(
      _$LessonVocabularyImpl(
        word: null == word
            ? _value.word
            : word // ignore: cast_nullable_to_non_nullable
                  as String,
        definition: null == definition
            ? _value.definition
            : definition // ignore: cast_nullable_to_non_nullable
                  as String,
        example: freezed == example
            ? _value.example
            : example // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonVocabularyImpl implements _LessonVocabulary {
  const _$LessonVocabularyImpl({
    required this.word,
    required this.definition,
    this.example,
  });

  factory _$LessonVocabularyImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonVocabularyImplFromJson(json);

  @override
  final String word;
  @override
  final String definition;
  @override
  final String? example;

  @override
  String toString() {
    return 'LessonVocabulary(word: $word, definition: $definition, example: $example)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonVocabularyImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.definition, definition) ||
                other.definition == definition) &&
            (identical(other.example, example) || other.example == example));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, word, definition, example);

  /// Create a copy of LessonVocabulary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonVocabularyImplCopyWith<_$LessonVocabularyImpl> get copyWith =>
      __$$LessonVocabularyImplCopyWithImpl<_$LessonVocabularyImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonVocabularyImplToJson(this);
  }
}

abstract class _LessonVocabulary implements LessonVocabulary {
  const factory _LessonVocabulary({
    required final String word,
    required final String definition,
    final String? example,
  }) = _$LessonVocabularyImpl;

  factory _LessonVocabulary.fromJson(Map<String, dynamic> json) =
      _$LessonVocabularyImpl.fromJson;

  @override
  String get word;
  @override
  String get definition;
  @override
  String? get example;

  /// Create a copy of LessonVocabulary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonVocabularyImplCopyWith<_$LessonVocabularyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonProgress _$LessonProgressFromJson(Map<String, dynamic> json) {
  return _LessonProgress.fromJson(json);
}

/// @nodoc
mixin _$LessonProgress {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  double get completionPercentage => throw _privateConstructorUsedError;
  int get earnedXp => throw _privateConstructorUsedError;
  Map<String, dynamic>? get mistakes => throw _privateConstructorUsedError;

  /// Serializes this LessonProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonProgressCopyWith<LessonProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonProgressCopyWith<$Res> {
  factory $LessonProgressCopyWith(
    LessonProgress value,
    $Res Function(LessonProgress) then,
  ) = _$LessonProgressCopyWithImpl<$Res, LessonProgress>;
  @useResult
  $Res call({
    String id,
    String userId,
    String lessonId,
    DateTime? startedAt,
    DateTime? completedAt,
    double completionPercentage,
    int earnedXp,
    Map<String, dynamic>? mistakes,
  });
}

/// @nodoc
class _$LessonProgressCopyWithImpl<$Res, $Val extends LessonProgress>
    implements $LessonProgressCopyWith<$Res> {
  _$LessonProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? lessonId = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? completionPercentage = null,
    Object? earnedXp = null,
    Object? mistakes = freezed,
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
            lessonId: null == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completionPercentage: null == completionPercentage
                ? _value.completionPercentage
                : completionPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            earnedXp: null == earnedXp
                ? _value.earnedXp
                : earnedXp // ignore: cast_nullable_to_non_nullable
                      as int,
            mistakes: freezed == mistakes
                ? _value.mistakes
                : mistakes // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LessonProgressImplCopyWith<$Res>
    implements $LessonProgressCopyWith<$Res> {
  factory _$$LessonProgressImplCopyWith(
    _$LessonProgressImpl value,
    $Res Function(_$LessonProgressImpl) then,
  ) = __$$LessonProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String lessonId,
    DateTime? startedAt,
    DateTime? completedAt,
    double completionPercentage,
    int earnedXp,
    Map<String, dynamic>? mistakes,
  });
}

/// @nodoc
class __$$LessonProgressImplCopyWithImpl<$Res>
    extends _$LessonProgressCopyWithImpl<$Res, _$LessonProgressImpl>
    implements _$$LessonProgressImplCopyWith<$Res> {
  __$$LessonProgressImplCopyWithImpl(
    _$LessonProgressImpl _value,
    $Res Function(_$LessonProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? lessonId = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? completionPercentage = null,
    Object? earnedXp = null,
    Object? mistakes = freezed,
  }) {
    return _then(
      _$LessonProgressImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonId: null == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completionPercentage: null == completionPercentage
            ? _value.completionPercentage
            : completionPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        earnedXp: null == earnedXp
            ? _value.earnedXp
            : earnedXp // ignore: cast_nullable_to_non_nullable
                  as int,
        mistakes: freezed == mistakes
            ? _value._mistakes
            : mistakes // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonProgressImpl implements _LessonProgress {
  const _$LessonProgressImpl({
    required this.id,
    required this.userId,
    required this.lessonId,
    this.startedAt,
    this.completedAt,
    this.completionPercentage = 0.0,
    this.earnedXp = 0,
    final Map<String, dynamic>? mistakes,
  }) : _mistakes = mistakes;

  factory _$LessonProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String lessonId;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final double completionPercentage;
  @override
  @JsonKey()
  final int earnedXp;
  final Map<String, dynamic>? _mistakes;
  @override
  Map<String, dynamic>? get mistakes {
    final value = _mistakes;
    if (value == null) return null;
    if (_mistakes is EqualUnmodifiableMapView) return _mistakes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'LessonProgress(id: $id, userId: $userId, lessonId: $lessonId, startedAt: $startedAt, completedAt: $completedAt, completionPercentage: $completionPercentage, earnedXp: $earnedXp, mistakes: $mistakes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            (identical(other.earnedXp, earnedXp) ||
                other.earnedXp == earnedXp) &&
            const DeepCollectionEquality().equals(other._mistakes, _mistakes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    lessonId,
    startedAt,
    completedAt,
    completionPercentage,
    earnedXp,
    const DeepCollectionEquality().hash(_mistakes),
  );

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      __$$LessonProgressImplCopyWithImpl<_$LessonProgressImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonProgressImplToJson(this);
  }
}

abstract class _LessonProgress implements LessonProgress {
  const factory _LessonProgress({
    required final String id,
    required final String userId,
    required final String lessonId,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final double completionPercentage,
    final int earnedXp,
    final Map<String, dynamic>? mistakes,
  }) = _$LessonProgressImpl;

  factory _LessonProgress.fromJson(Map<String, dynamic> json) =
      _$LessonProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get lessonId;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  double get completionPercentage;
  @override
  int get earnedXp;
  @override
  Map<String, dynamic>? get mistakes;

  /// Create a copy of LessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonProgressImplCopyWith<_$LessonProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
