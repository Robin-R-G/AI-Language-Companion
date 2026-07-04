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
  int get estimatedMinutes => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<LessonQuiz> get quizzes => throw _privateConstructorUsedError;
  int get earnedXp => throw _privateConstructorUsedError;
  double get completionPercentage => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

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
    int estimatedMinutes,
    String content,
    List<LessonQuiz> quizzes,
    int earnedXp,
    double completionPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
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
    Object? estimatedMinutes = null,
    Object? content = null,
    Object? quizzes = null,
    Object? earnedXp = null,
    Object? completionPercentage = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
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
            estimatedMinutes: null == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            quizzes: null == quizzes
                ? _value.quizzes
                : quizzes // ignore: cast_nullable_to_non_nullable
                      as List<LessonQuiz>,
            earnedXp: null == earnedXp
                ? _value.earnedXp
                : earnedXp // ignore: cast_nullable_to_non_nullable
                      as int,
            completionPercentage: null == completionPercentage
                ? _value.completionPercentage
                : completionPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
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
    int estimatedMinutes,
    String content,
    List<LessonQuiz> quizzes,
    int earnedXp,
    double completionPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
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
    Object? estimatedMinutes = null,
    Object? content = null,
    Object? quizzes = null,
    Object? earnedXp = null,
    Object? completionPercentage = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
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
        estimatedMinutes: null == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        quizzes: null == quizzes
            ? _value._quizzes
            : quizzes // ignore: cast_nullable_to_non_nullable
                  as List<LessonQuiz>,
        earnedXp: null == earnedXp
            ? _value.earnedXp
            : earnedXp // ignore: cast_nullable_to_non_nullable
                  as int,
        completionPercentage: null == completionPercentage
            ? _value.completionPercentage
            : completionPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$LessonImpl implements _Lesson {
  const _$LessonImpl({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    this.estimatedMinutes = 15,
    this.content = '',
    final List<LessonQuiz> quizzes = const [],
    this.earnedXp = 0,
    this.completionPercentage = 0.0,
    this.startedAt,
    this.completedAt,
  }) : _quizzes = quizzes;

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
  @JsonKey()
  final int estimatedMinutes;
  @override
  @JsonKey()
  final String content;
  final List<LessonQuiz> _quizzes;
  @override
  @JsonKey()
  List<LessonQuiz> get quizzes {
    if (_quizzes is EqualUnmodifiableListView) return _quizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizzes);
  }

  @override
  @JsonKey()
  final int earnedXp;
  @override
  @JsonKey()
  final double completionPercentage;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, category: $category, difficulty: $difficulty, estimatedMinutes: $estimatedMinutes, content: $content, quizzes: $quizzes, earnedXp: $earnedXp, completionPercentage: $completionPercentage, startedAt: $startedAt, completedAt: $completedAt)';
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
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._quizzes, _quizzes) &&
            (identical(other.earnedXp, earnedXp) ||
                other.earnedXp == earnedXp) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
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
    title,
    category,
    difficulty,
    estimatedMinutes,
    content,
    const DeepCollectionEquality().hash(_quizzes),
    earnedXp,
    completionPercentage,
    startedAt,
    completedAt,
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
    final int estimatedMinutes,
    final String content,
    final List<LessonQuiz> quizzes,
    final int earnedXp,
    final double completionPercentage,
    final DateTime? startedAt,
    final DateTime? completedAt,
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
  int get estimatedMinutes;
  @override
  String get content;
  @override
  List<LessonQuiz> get quizzes;
  @override
  int get earnedXp;
  @override
  double get completionPercentage;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;

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
  String get explanation => throw _privateConstructorUsedError;

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
    String explanation,
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
    Object? explanation = null,
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
    String explanation,
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
    Object? explanation = null,
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
class _$LessonQuizImpl implements _LessonQuiz {
  const _$LessonQuizImpl({
    required this.questionId,
    required this.question,
    required final List<String> options,
    required this.correctOptionIndex,
    this.explanation = '',
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
  @JsonKey()
  final String explanation;

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
    final String explanation,
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
  String get explanation;

  /// Create a copy of LessonQuiz
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonQuizImplCopyWith<_$LessonQuizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
