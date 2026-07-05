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
  String get userId => throw _privateConstructorUsedError;
  String get examType => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get questionsAnswered => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;
  double get estimatedScore => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Map<String, dynamic> get feedback => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

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
    String userId,
    String examType,
    String section,
    int durationMinutes,
    int totalQuestions,
    int questionsAnswered,
    int correctAnswers,
    double estimatedScore,
    String status,
    Map<String, dynamic> feedback,
    DateTime startedAt,
    DateTime? completedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? userId = null,
    Object? examType = null,
    Object? section = null,
    Object? durationMinutes = null,
    Object? totalQuestions = null,
    Object? questionsAnswered = null,
    Object? correctAnswers = null,
    Object? estimatedScore = null,
    Object? status = null,
    Object? feedback = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
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
            examType: null == examType
                ? _value.examType
                : examType // ignore: cast_nullable_to_non_nullable
                      as String,
            section: null == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            totalQuestions: null == totalQuestions
                ? _value.totalQuestions
                : totalQuestions // ignore: cast_nullable_to_non_nullable
                      as int,
            questionsAnswered: null == questionsAnswered
                ? _value.questionsAnswered
                : questionsAnswered // ignore: cast_nullable_to_non_nullable
                      as int,
            correctAnswers: null == correctAnswers
                ? _value.correctAnswers
                : correctAnswers // ignore: cast_nullable_to_non_nullable
                      as int,
            estimatedScore: null == estimatedScore
                ? _value.estimatedScore
                : estimatedScore // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            feedback: null == feedback
                ? _value.feedback
                : feedback // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
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
    String userId,
    String examType,
    String section,
    int durationMinutes,
    int totalQuestions,
    int questionsAnswered,
    int correctAnswers,
    double estimatedScore,
    String status,
    Map<String, dynamic> feedback,
    DateTime startedAt,
    DateTime? completedAt,
    DateTime createdAt,
    DateTime updatedAt,
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
    Object? userId = null,
    Object? examType = null,
    Object? section = null,
    Object? durationMinutes = null,
    Object? totalQuestions = null,
    Object? questionsAnswered = null,
    Object? correctAnswers = null,
    Object? estimatedScore = null,
    Object? status = null,
    Object? feedback = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MockExamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        examType: null == examType
            ? _value.examType
            : examType // ignore: cast_nullable_to_non_nullable
                  as String,
        section: null == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        totalQuestions: null == totalQuestions
            ? _value.totalQuestions
            : totalQuestions // ignore: cast_nullable_to_non_nullable
                  as int,
        questionsAnswered: null == questionsAnswered
            ? _value.questionsAnswered
            : questionsAnswered // ignore: cast_nullable_to_non_nullable
                  as int,
        correctAnswers: null == correctAnswers
            ? _value.correctAnswers
            : correctAnswers // ignore: cast_nullable_to_non_nullable
                  as int,
        estimatedScore: null == estimatedScore
            ? _value.estimatedScore
            : estimatedScore // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        feedback: null == feedback
            ? _value._feedback
            : feedback // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
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
class _$MockExamImpl implements _MockExam {
  const _$MockExamImpl({
    required this.id,
    required this.userId,
    required this.examType,
    required this.section,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.estimatedScore,
    required this.status,
    required final Map<String, dynamic> feedback,
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : _feedback = feedback;

  factory _$MockExamImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String examType;
  @override
  final String section;
  @override
  final int durationMinutes;
  @override
  final int totalQuestions;
  @override
  final int questionsAnswered;
  @override
  final int correctAnswers;
  @override
  final double estimatedScore;
  @override
  final String status;
  final Map<String, dynamic> _feedback;
  @override
  Map<String, dynamic> get feedback {
    if (_feedback is EqualUnmodifiableMapView) return _feedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_feedback);
  }

  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'MockExam(id: $id, userId: $userId, examType: $examType, section: $section, durationMinutes: $durationMinutes, totalQuestions: $totalQuestions, questionsAnswered: $questionsAnswered, correctAnswers: $correctAnswers, estimatedScore: $estimatedScore, status: $status, feedback: $feedback, startedAt: $startedAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.examType, examType) ||
                other.examType == examType) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.questionsAnswered, questionsAnswered) ||
                other.questionsAnswered == questionsAnswered) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers) &&
            (identical(other.estimatedScore, estimatedScore) ||
                other.estimatedScore == estimatedScore) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._feedback, _feedback) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
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
    examType,
    section,
    durationMinutes,
    totalQuestions,
    questionsAnswered,
    correctAnswers,
    estimatedScore,
    status,
    const DeepCollectionEquality().hash(_feedback),
    startedAt,
    completedAt,
    createdAt,
    updatedAt,
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
    required final String userId,
    required final String examType,
    required final String section,
    required final int durationMinutes,
    required final int totalQuestions,
    required final int questionsAnswered,
    required final int correctAnswers,
    required final double estimatedScore,
    required final String status,
    required final Map<String, dynamic> feedback,
    required final DateTime startedAt,
    final DateTime? completedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$MockExamImpl;

  factory _MockExam.fromJson(Map<String, dynamic> json) =
      _$MockExamImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get examType;
  @override
  String get section;
  @override
  int get durationMinutes;
  @override
  int get totalQuestions;
  @override
  int get questionsAnswered;
  @override
  int get correctAnswers;
  @override
  double get estimatedScore;
  @override
  String get status;
  @override
  Map<String, dynamic> get feedback;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of MockExam
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamImplCopyWith<_$MockExamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MockExamQuestion _$MockExamQuestionFromJson(Map<String, dynamic> json) {
  return _MockExamQuestion.fromJson(json);
}

/// @nodoc
mixin _$MockExamQuestion {
  String get id => throw _privateConstructorUsedError;
  String get examId => throw _privateConstructorUsedError;
  int get questionNumber => throw _privateConstructorUsedError;
  String get questionType => throw _privateConstructorUsedError;
  String get prompt => throw _privateConstructorUsedError;
  Map<String, dynamic> get options => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  String? get userAnswer => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MockExamQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MockExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MockExamQuestionCopyWith<MockExamQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MockExamQuestionCopyWith<$Res> {
  factory $MockExamQuestionCopyWith(
    MockExamQuestion value,
    $Res Function(MockExamQuestion) then,
  ) = _$MockExamQuestionCopyWithImpl<$Res, MockExamQuestion>;
  @useResult
  $Res call({
    String id,
    String examId,
    int questionNumber,
    String questionType,
    String prompt,
    Map<String, dynamic> options,
    String correctAnswer,
    String? userAnswer,
    bool isCorrect,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MockExamQuestionCopyWithImpl<$Res, $Val extends MockExamQuestion>
    implements $MockExamQuestionCopyWith<$Res> {
  _$MockExamQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MockExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? questionNumber = null,
    Object? questionType = null,
    Object? prompt = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? userAnswer = freezed,
    Object? isCorrect = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            examId: null == examId
                ? _value.examId
                : examId // ignore: cast_nullable_to_non_nullable
                      as String,
            questionNumber: null == questionNumber
                ? _value.questionNumber
                : questionNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            questionType: null == questionType
                ? _value.questionType
                : questionType // ignore: cast_nullable_to_non_nullable
                      as String,
            prompt: null == prompt
                ? _value.prompt
                : prompt // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            correctAnswer: null == correctAnswer
                ? _value.correctAnswer
                : correctAnswer // ignore: cast_nullable_to_non_nullable
                      as String,
            userAnswer: freezed == userAnswer
                ? _value.userAnswer
                : userAnswer // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCorrect: null == isCorrect
                ? _value.isCorrect
                : isCorrect // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MockExamQuestionImplCopyWith<$Res>
    implements $MockExamQuestionCopyWith<$Res> {
  factory _$$MockExamQuestionImplCopyWith(
    _$MockExamQuestionImpl value,
    $Res Function(_$MockExamQuestionImpl) then,
  ) = __$$MockExamQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String examId,
    int questionNumber,
    String questionType,
    String prompt,
    Map<String, dynamic> options,
    String correctAnswer,
    String? userAnswer,
    bool isCorrect,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MockExamQuestionImplCopyWithImpl<$Res>
    extends _$MockExamQuestionCopyWithImpl<$Res, _$MockExamQuestionImpl>
    implements _$$MockExamQuestionImplCopyWith<$Res> {
  __$$MockExamQuestionImplCopyWithImpl(
    _$MockExamQuestionImpl _value,
    $Res Function(_$MockExamQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MockExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? examId = null,
    Object? questionNumber = null,
    Object? questionType = null,
    Object? prompt = null,
    Object? options = null,
    Object? correctAnswer = null,
    Object? userAnswer = freezed,
    Object? isCorrect = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$MockExamQuestionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        examId: null == examId
            ? _value.examId
            : examId // ignore: cast_nullable_to_non_nullable
                  as String,
        questionNumber: null == questionNumber
            ? _value.questionNumber
            : questionNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        questionType: null == questionType
            ? _value.questionType
            : questionType // ignore: cast_nullable_to_non_nullable
                  as String,
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        correctAnswer: null == correctAnswer
            ? _value.correctAnswer
            : correctAnswer // ignore: cast_nullable_to_non_nullable
                  as String,
        userAnswer: freezed == userAnswer
            ? _value.userAnswer
            : userAnswer // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCorrect: null == isCorrect
            ? _value.isCorrect
            : isCorrect // ignore: cast_nullable_to_non_nullable
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
class _$MockExamQuestionImpl implements _MockExamQuestion {
  const _$MockExamQuestionImpl({
    required this.id,
    required this.examId,
    required this.questionNumber,
    required this.questionType,
    required this.prompt,
    required final Map<String, dynamic> options,
    required this.correctAnswer,
    this.userAnswer,
    required this.isCorrect,
    required this.createdAt,
  }) : _options = options;

  factory _$MockExamQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MockExamQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String examId;
  @override
  final int questionNumber;
  @override
  final String questionType;
  @override
  final String prompt;
  final Map<String, dynamic> _options;
  @override
  Map<String, dynamic> get options {
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_options);
  }

  @override
  final String correctAnswer;
  @override
  final String? userAnswer;
  @override
  final bool isCorrect;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MockExamQuestion(id: $id, examId: $examId, questionNumber: $questionNumber, questionType: $questionType, prompt: $prompt, options: $options, correctAnswer: $correctAnswer, userAnswer: $userAnswer, isCorrect: $isCorrect, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MockExamQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.examId, examId) || other.examId == examId) &&
            (identical(other.questionNumber, questionNumber) ||
                other.questionNumber == questionNumber) &&
            (identical(other.questionType, questionType) ||
                other.questionType == questionType) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.userAnswer, userAnswer) ||
                other.userAnswer == userAnswer) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    examId,
    questionNumber,
    questionType,
    prompt,
    const DeepCollectionEquality().hash(_options),
    correctAnswer,
    userAnswer,
    isCorrect,
    createdAt,
  );

  /// Create a copy of MockExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MockExamQuestionImplCopyWith<_$MockExamQuestionImpl> get copyWith =>
      __$$MockExamQuestionImplCopyWithImpl<_$MockExamQuestionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MockExamQuestionImplToJson(this);
  }
}

abstract class _MockExamQuestion implements MockExamQuestion {
  const factory _MockExamQuestion({
    required final String id,
    required final String examId,
    required final int questionNumber,
    required final String questionType,
    required final String prompt,
    required final Map<String, dynamic> options,
    required final String correctAnswer,
    final String? userAnswer,
    required final bool isCorrect,
    required final DateTime createdAt,
  }) = _$MockExamQuestionImpl;

  factory _MockExamQuestion.fromJson(Map<String, dynamic> json) =
      _$MockExamQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get examId;
  @override
  int get questionNumber;
  @override
  String get questionType;
  @override
  String get prompt;
  @override
  Map<String, dynamic> get options;
  @override
  String get correctAnswer;
  @override
  String? get userAnswer;
  @override
  bool get isCorrect;
  @override
  DateTime get createdAt;

  /// Create a copy of MockExamQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MockExamQuestionImplCopyWith<_$MockExamQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExamSectionResult _$ExamSectionResultFromJson(Map<String, dynamic> json) {
  return _ExamSectionResult.fromJson(json);
}

/// @nodoc
mixin _$ExamSectionResult {
  String get section => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get band => throw _privateConstructorUsedError;
  Map<String, dynamic> get details => throw _privateConstructorUsedError;

  /// Serializes this ExamSectionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExamSectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExamSectionResultCopyWith<ExamSectionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExamSectionResultCopyWith<$Res> {
  factory $ExamSectionResultCopyWith(
    ExamSectionResult value,
    $Res Function(ExamSectionResult) then,
  ) = _$ExamSectionResultCopyWithImpl<$Res, ExamSectionResult>;
  @useResult
  $Res call({
    String section,
    double score,
    String band,
    Map<String, dynamic> details,
  });
}

/// @nodoc
class _$ExamSectionResultCopyWithImpl<$Res, $Val extends ExamSectionResult>
    implements $ExamSectionResultCopyWith<$Res> {
  _$ExamSectionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExamSectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? section = null,
    Object? score = null,
    Object? band = null,
    Object? details = null,
  }) {
    return _then(
      _value.copyWith(
            section: null == section
                ? _value.section
                : section // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            band: null == band
                ? _value.band
                : band // ignore: cast_nullable_to_non_nullable
                      as String,
            details: null == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExamSectionResultImplCopyWith<$Res>
    implements $ExamSectionResultCopyWith<$Res> {
  factory _$$ExamSectionResultImplCopyWith(
    _$ExamSectionResultImpl value,
    $Res Function(_$ExamSectionResultImpl) then,
  ) = __$$ExamSectionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String section,
    double score,
    String band,
    Map<String, dynamic> details,
  });
}

/// @nodoc
class __$$ExamSectionResultImplCopyWithImpl<$Res>
    extends _$ExamSectionResultCopyWithImpl<$Res, _$ExamSectionResultImpl>
    implements _$$ExamSectionResultImplCopyWith<$Res> {
  __$$ExamSectionResultImplCopyWithImpl(
    _$ExamSectionResultImpl _value,
    $Res Function(_$ExamSectionResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExamSectionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? section = null,
    Object? score = null,
    Object? band = null,
    Object? details = null,
  }) {
    return _then(
      _$ExamSectionResultImpl(
        section: null == section
            ? _value.section
            : section // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        band: null == band
            ? _value.band
            : band // ignore: cast_nullable_to_non_nullable
                  as String,
        details: null == details
            ? _value._details
            : details // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExamSectionResultImpl implements _ExamSectionResult {
  const _$ExamSectionResultImpl({
    required this.section,
    required this.score,
    required this.band,
    required final Map<String, dynamic> details,
  }) : _details = details;

  factory _$ExamSectionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExamSectionResultImplFromJson(json);

  @override
  final String section;
  @override
  final double score;
  @override
  final String band;
  final Map<String, dynamic> _details;
  @override
  Map<String, dynamic> get details {
    if (_details is EqualUnmodifiableMapView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_details);
  }

  @override
  String toString() {
    return 'ExamSectionResult(section: $section, score: $score, band: $band, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExamSectionResultImpl &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.band, band) || other.band == band) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    section,
    score,
    band,
    const DeepCollectionEquality().hash(_details),
  );

  /// Create a copy of ExamSectionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExamSectionResultImplCopyWith<_$ExamSectionResultImpl> get copyWith =>
      __$$ExamSectionResultImplCopyWithImpl<_$ExamSectionResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExamSectionResultImplToJson(this);
  }
}

abstract class _ExamSectionResult implements ExamSectionResult {
  const factory _ExamSectionResult({
    required final String section,
    required final double score,
    required final String band,
    required final Map<String, dynamic> details,
  }) = _$ExamSectionResultImpl;

  factory _ExamSectionResult.fromJson(Map<String, dynamic> json) =
      _$ExamSectionResultImpl.fromJson;

  @override
  String get section;
  @override
  double get score;
  @override
  String get band;
  @override
  Map<String, dynamic> get details;

  /// Create a copy of ExamSectionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExamSectionResultImplCopyWith<_$ExamSectionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
