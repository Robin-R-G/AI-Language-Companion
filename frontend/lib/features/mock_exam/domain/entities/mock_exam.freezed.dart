// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mock_exam.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MockExam _$MockExamFromJson(Map<String, dynamic> json) {
  return _MockExam.fromJson(json);
}

/// @nodoc
mixin _$MockExam {
  String get id => throw _privateConstructorUsedError;
  String get examType => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get answeredQuestions => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  List<ExamQuestion> get questions => throw _privateConstructorUsedError;
  String get bandScore => throw _privateConstructorUsedError;

  /// Serializes this MockExam to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamCopyWith<MockExam> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamCopyWith<$Res> {
  factory $MockExamCopyWith(MockExam value, $Res Function(MockExam) then) =
      _$MockExamCopyWithImpl<$Res, MockExam>;
  @useResult
  $Res call({
    String id,
    String examType,
    String section,
    String title,
    String description,
    int durationMinutes,
    int totalQuestions,
    int answeredQuestions,
    double score,
    String status,
    DateTime? startedAt,
    DateTime? completedAt,
    List<ExamQuestion> questions,
    String bandScore,
  });
}

/// @nodoc
class _$MockExamCopyWithImpl<$Res, $Val extends MockExam>
    implements $MockExamCopyWith<$Res> {
  _$MockExamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examType = null,
    Object? section = null,
    Object? title = null,
    Object? description = null,
    Object? durationMinutes = null,
    Object? totalQuestions = null,
    Object? answeredQuestions = null,
    Object? score = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? questions = null,
    Object? bandScore = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            examType: null == examType
                ? _value.examType
                : examType // ignore: cast_nullable_to_non_nullable
                      as String,
            section: null == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            answeredQuestions: null == answeredQuestions
                ? _value.answeredQuestions
                : answeredQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            questions: null == questions
                ? _value.questions
                : questions // ignore: cast_nullable_to_non_nullable
                      as List<ExamQuestion>,
            bandScore: null == bandScore
                ? _value.bandScore
                : bandScore // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MockExamImplCopyWith<$Res>
    implements $MockExamCopyWith<$Res> {
  factory _$$MockExamImplCopyWith(
    _$MockExamImpl value,
    $Res Function(_$MockExamImpl) then,
  ) = __$$MockExamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String examType,
    String section,
    String title,
    String description,
    int durationMinutes,
    int totalQuestions,
    int answeredQuestions,
    double score,
    String status,
    DateTime? startedAt,
    DateTime? completedAt,
    List<ExamQuestion> questions,
    String bandScore,
  });
}

/// @nodoc
class __$$MockExamImplCopyWithImpl<$Res>
    extends _$MockExamCopyWithImpl<$Res, _$MockExamImpl>
    implements _$$MockExamImplCopyWith<$Res> {
  __$$MockExamImplCopyWithImpl(
    _$MockExamImpl _value,
    $Res Function(_$MockExamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examType = null,
    Object? section = null,
    Object? title = null,
    Object? description = null,
    Object? durationMinutes = null,
    Object? totalQuestions = null,
    Object? answeredQuestions = null,
    Object? score = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? questions = null,
    Object? bandScore = null,
  }) {
    return _then(
      _$MockExamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        examType: null == examType
            ? _value.examType
            : examType // ignore: cast_nullable_to_non_nullable
                  as String,
        section: null == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        answeredQuestions: null == answeredQuestions
            ? _value.answeredQuestions
            : answeredQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<ExamQuestion>,
        bandScore: null == bandScore
            ? _value.bandScore
            : bandScore // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MockExamImpl implements _MockExam {
  const _$MockExamImpl({
    required this.id,
    required this.examType,
    required this.section,
    required this.title,
    this.description = '',
    this.durationMinutes = 0,
    this.totalQuestions = 0,
    this.answeredQuestions = 0,
    this.score = 0.0,
    this.status = 'not_started',
    this.startedAt,
    this.completedAt,
    final List<ExamQuestion> questions = const [],
    this.bandScore = '',
  }) : _questions = questions;

  factory _$MockExamImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamImplFromJson(json);

  @override
  final String id;
  @override
  final String examType;
  @override
  final String section;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final int durationMinutes;
  @override
  @JsonKey()
  final int totalQuestions;
  @override
  @JsonKey()
  final int answeredQuestions;
  @override
  @JsonKey()
  final double score;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  final List<ExamQuestion> _questions;
  @override
  @JsonKey()
  List<ExamQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  @JsonKey()
  final String bandScore;

  @override
  String toString() {
    return 'MockExam(id: $id, examType: $examType, section: $section, title: $title, description: $description, durationMinutes: $durationMinutes, totalQuestions: $totalQuestions, answeredQuestions: $answeredQuestions, score: $score, status: $status, startedAt: $startedAt, completedAt: $completedAt, questions: $questions, bandScore: $bandScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examType, examType) ||
                other.examType == examType) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.answeredQuestions, answeredQuestions) ||
                other.answeredQuestions == answeredQuestions) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.bandScore, bandScore) ||
                other.bandScore == bandScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examType,
    section,
    title,
    description,
    durationMinutes,
    totalQuestions,
    answeredQuestions,
    score,
    status,
    startedAt,
    completedAt,
    const DeepCollectionEquality().hash(_questions),
    bandScore,
  );

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamImplCopyWith<_$MockExamImpl> get copyWith =>
      __$$MockExamImplCopyWithImpl<_$MockExamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamImplToJson(this);
  }
}

abstract class _MockExam implements MockExam {
  const factory _MockExam({
    required final String id,
    required final String examType,
    required final String section,
    required final String title,
    final String description,
    final int durationMinutes,
    final int totalQuestions,
    final int answeredQuestions,
    final double score,
    final String status,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final List<ExamQuestion> questions,
    final String bandScore,
  }) = _$MockExamImpl;

  factory _MockExam.fromJson(Map<String, dynamic> json) =
      _$MockExamImpl.fromJson;

  @override
  String get id;
  @override
  String get examType;
  @override
  String get section;
  @override
  String get title;
  @override
  String get description;
  @override
  int get durationMinutes;
  @override
  int get totalQuestions;
  @override
  int get answeredQuestions;
  @override
  double get score;
  @override
  String get status;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;
  @override
  List<ExamQuestion> get questions;
  @override
  String get bandScore;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamImplCopyWith<_$MockExamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamQuestion _$ExamQuestionFromJson(Map<String, dynamic> json) {
  return _ExamQuestion.fromJson(json);
}

/// @nodoc
mixin _$ExamQuestion {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  String get userAnswer => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  int get timeSpentSeconds => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  /// Serializes this ExamQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamQuestionCopyWith<ExamQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamQuestionCopyWith<$Res> {
  factory $ExamQuestionCopyWith(
    ExamQuestion value,
    $Res Function(ExamQuestion) then,
  ) = _$ExamQuestionCopyWithImpl<$Res, ExamQuestion>;
  @useResult
  $Res call({
    String id,
    String question,
    String type,
    List<String> options,
    String correctAnswer,
    String userAnswer,
    bool isCorrect,
    int timeSpentSeconds,
    String explanation,
  });
}

/// @nodoc
class _$ExamQuestionCopyWithImpl<$Res, $Val extends ExamQuestion>
    implements $ExamQuestionCopyWith<$Res> {
  _$ExamQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? type = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? userAnswer = null,
    Object? isCorrect = null,
    Object? timeSpentSeconds = null,
    Object? explanation = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            userAnswer: null == userAnswer
                ? _value.userAnswer
                : userAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
                      as bool,
            timeSpentSeconds: null == timeSpentSeconds
                ? _value.timeSpentSeconds
                : timeSpentSeconds // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ExamQuestionImplCopyWith<$Res>
    implements $ExamQuestionCopyWith<$Res> {
  factory _$$ExamQuestionImplCopyWith(
    _$ExamQuestionImpl value,
    $Res Function(_$ExamQuestionImpl) then,
  ) = __$$ExamQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String question,
    String type,
    List<String> options,
    String correctAnswer,
    String userAnswer,
    bool isCorrect,
    int timeSpentSeconds,
    String explanation,
  });
}

/// @nodoc
class __$$ExamQuestionImplCopyWithImpl<$Res>
    extends _$ExamQuestionCopyWithImpl<$Res, _$ExamQuestionImpl>
    implements _$$ExamQuestionImplCopyWith<$Res> {
  __$$ExamQuestionImplCopyWithImpl(
    _$ExamQuestionImpl _value,
    $Res Function(_$ExamQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? type = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? userAnswer = null,
    Object? isCorrect = null,
    Object? timeSpentSeconds = null,
    Object? explanation = null,
  }) {
    return _then(
      _$ExamQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        userAnswer: null == userAnswer
            ? _value.userAnswer
            : userAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
                  as bool,
        timeSpentSeconds: null == timeSpentSeconds
            ? _value.timeSpentSeconds
            : timeSpentSeconds // ignore: cast_nullable_to_non_nullable
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
class _$ExamQuestionImpl implements _ExamQuestion {
  const _$ExamQuestionImpl({
    required this.id,
    required this.question,
    required this.type,
    final List<String> options = const [],
    this.correctAnswer = '',
    this.userAnswer = '',
    this.isCorrect = false,
    this.timeSpentSeconds = 0,
    this.explanation = '',
  }) : _options = options;

  factory _$ExamQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String question;
  @override
  final String type;
  final List<String> _options;
  @override
  @JsonKey()
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  @JsonKey()
  final String correctAnswer;
  @override
  @JsonKey()
  final String userAnswer;
  @override
  @JsonKey()
  final bool isCorrect;
  @override
  @JsonKey()
  final int timeSpentSeconds;
  @override
  @JsonKey()
  final String explanation;

  @override
  String toString() {
    return 'ExamQuestion(id: $id, question: $question, type: $type, options: $options, correctAnswer: $correctAnswer, userAnswer: $userAnswer, isCorrect: $isCorrect, timeSpentSeconds: $timeSpentSeconds, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.userAnswer, userAnswer) ||
                other.userAnswer == userAnswer) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.timeSpentSeconds, timeSpentSeconds) ||
                other.timeSpentSeconds == timeSpentSeconds) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    question,
    type,
    const DeepCollectionEquality().hash(_options),
    correctAnswer,
    userAnswer,
    isCorrect,
    timeSpentSeconds,
    explanation,
  );

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamQuestionImplCopyWith<_$ExamQuestionImpl> get copyWith =>
      __$$ExamQuestionImplCopyWithImpl<_$ExamQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamQuestionImplToJson(this);
  }
}

abstract class _ExamQuestion implements ExamQuestion {
  const factory _ExamQuestion({
    required final String id,
    required final String question,
    required final String type,
    final List<String> options,
    final String correctAnswer,
    final String userAnswer,
    final bool isCorrect,
    final int timeSpentSeconds,
    final String explanation,
  }) = _$ExamQuestionImpl;

  factory _ExamQuestion.fromJson(Map<String, dynamic> json) =
      _$ExamQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get question;
  @override
  String get type;
  @override
  List<String> get options;
  @override
  String get correctAnswer;
  @override
  String get userAnswer;
  @override
  bool get isCorrect;
  @override
  int get timeSpentSeconds;
  @override
  String get explanation;

  /// Create a copy of ExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamQuestionImplCopyWith<_$ExamQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
