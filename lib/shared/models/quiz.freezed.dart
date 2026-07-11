// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuizQuestion {

 String get id; String get type; String get text; List<String>? get options; String get correctAnswer; int get points; String? get explanation; String? get altText; String? get ttsReadout; String? get explanationTtsReadout;
/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizQuestionCopyWith<QuizQuestion> get copyWith => _$QuizQuestionCopyWithImpl<QuizQuestion>(this as QuizQuestion, _$identity);

  /// Serializes this QuizQuestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&(identical(other.points, points) || other.points == points)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.ttsReadout, ttsReadout) || other.ttsReadout == ttsReadout)&&(identical(other.explanationTtsReadout, explanationTtsReadout) || other.explanationTtsReadout == explanationTtsReadout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,text,const DeepCollectionEquality().hash(options),correctAnswer,points,explanation,altText,ttsReadout,explanationTtsReadout);

@override
String toString() {
  return 'QuizQuestion(id: $id, type: $type, text: $text, options: $options, correctAnswer: $correctAnswer, points: $points, explanation: $explanation, altText: $altText, ttsReadout: $ttsReadout, explanationTtsReadout: $explanationTtsReadout)';
}


}

/// @nodoc
abstract mixin class $QuizQuestionCopyWith<$Res>  {
  factory $QuizQuestionCopyWith(QuizQuestion value, $Res Function(QuizQuestion) _then) = _$QuizQuestionCopyWithImpl;
@useResult
$Res call({
 String id, String type, String text, List<String>? options, String correctAnswer, int points, String? explanation, String? altText, String? ttsReadout, String? explanationTtsReadout
});




}
/// @nodoc
class _$QuizQuestionCopyWithImpl<$Res>
    implements $QuizQuestionCopyWith<$Res> {
  _$QuizQuestionCopyWithImpl(this._self, this._then);

  final QuizQuestion _self;
  final $Res Function(QuizQuestion) _then;

/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? text = null,Object? options = freezed,Object? correctAnswer = null,Object? points = null,Object? explanation = freezed,Object? altText = freezed,Object? ttsReadout = freezed,Object? explanationTtsReadout = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>?,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,ttsReadout: freezed == ttsReadout ? _self.ttsReadout : ttsReadout // ignore: cast_nullable_to_non_nullable
as String?,explanationTtsReadout: freezed == explanationTtsReadout ? _self.explanationTtsReadout : explanationTtsReadout // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuizQuestion].
extension QuizQuestionPatterns on QuizQuestion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuizQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuizQuestion value)  $default,){
final _that = this;
switch (_that) {
case _QuizQuestion():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuizQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String text,  List<String>? options,  String correctAnswer,  int points,  String? explanation,  String? altText,  String? ttsReadout,  String? explanationTtsReadout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
return $default(_that.id,_that.type,_that.text,_that.options,_that.correctAnswer,_that.points,_that.explanation,_that.altText,_that.ttsReadout,_that.explanationTtsReadout);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String text,  List<String>? options,  String correctAnswer,  int points,  String? explanation,  String? altText,  String? ttsReadout,  String? explanationTtsReadout)  $default,) {final _that = this;
switch (_that) {
case _QuizQuestion():
return $default(_that.id,_that.type,_that.text,_that.options,_that.correctAnswer,_that.points,_that.explanation,_that.altText,_that.ttsReadout,_that.explanationTtsReadout);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String text,  List<String>? options,  String correctAnswer,  int points,  String? explanation,  String? altText,  String? ttsReadout,  String? explanationTtsReadout)?  $default,) {final _that = this;
switch (_that) {
case _QuizQuestion() when $default != null:
return $default(_that.id,_that.type,_that.text,_that.options,_that.correctAnswer,_that.points,_that.explanation,_that.altText,_that.ttsReadout,_that.explanationTtsReadout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuizQuestion implements QuizQuestion {
  const _QuizQuestion({required this.id, required this.type, required this.text, final  List<String>? options, required this.correctAnswer, required this.points, this.explanation, this.altText, this.ttsReadout, this.explanationTtsReadout}): _options = options;
  factory _QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);

@override final  String id;
@override final  String type;
@override final  String text;
 final  List<String>? _options;
@override List<String>? get options {
  final value = _options;
  if (value == null) return null;
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String correctAnswer;
@override final  int points;
@override final  String? explanation;
@override final  String? altText;
@override final  String? ttsReadout;
@override final  String? explanationTtsReadout;

/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizQuestionCopyWith<_QuizQuestion> get copyWith => __$QuizQuestionCopyWithImpl<_QuizQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuizQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.correctAnswer, correctAnswer) || other.correctAnswer == correctAnswer)&&(identical(other.points, points) || other.points == points)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.altText, altText) || other.altText == altText)&&(identical(other.ttsReadout, ttsReadout) || other.ttsReadout == ttsReadout)&&(identical(other.explanationTtsReadout, explanationTtsReadout) || other.explanationTtsReadout == explanationTtsReadout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,text,const DeepCollectionEquality().hash(_options),correctAnswer,points,explanation,altText,ttsReadout,explanationTtsReadout);

@override
String toString() {
  return 'QuizQuestion(id: $id, type: $type, text: $text, options: $options, correctAnswer: $correctAnswer, points: $points, explanation: $explanation, altText: $altText, ttsReadout: $ttsReadout, explanationTtsReadout: $explanationTtsReadout)';
}


}

/// @nodoc
abstract mixin class _$QuizQuestionCopyWith<$Res> implements $QuizQuestionCopyWith<$Res> {
  factory _$QuizQuestionCopyWith(_QuizQuestion value, $Res Function(_QuizQuestion) _then) = __$QuizQuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String text, List<String>? options, String correctAnswer, int points, String? explanation, String? altText, String? ttsReadout, String? explanationTtsReadout
});




}
/// @nodoc
class __$QuizQuestionCopyWithImpl<$Res>
    implements _$QuizQuestionCopyWith<$Res> {
  __$QuizQuestionCopyWithImpl(this._self, this._then);

  final _QuizQuestion _self;
  final $Res Function(_QuizQuestion) _then;

/// Create a copy of QuizQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? text = null,Object? options = freezed,Object? correctAnswer = null,Object? points = null,Object? explanation = freezed,Object? altText = freezed,Object? ttsReadout = freezed,Object? explanationTtsReadout = freezed,}) {
  return _then(_QuizQuestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>?,correctAnswer: null == correctAnswer ? _self.correctAnswer : correctAnswer // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,altText: freezed == altText ? _self.altText : altText // ignore: cast_nullable_to_non_nullable
as String?,ttsReadout: freezed == ttsReadout ? _self.ttsReadout : ttsReadout // ignore: cast_nullable_to_non_nullable
as String?,explanationTtsReadout: freezed == explanationTtsReadout ? _self.explanationTtsReadout : explanationTtsReadout // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Quiz {

 String get id; String get courseId; String? get moduleId; String get title; String get description; int get timeLimit; bool get published; int get totalPoints; int? get accessibilityScore; List<QuizQuestion> get questions;
/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizCopyWith<Quiz> get copyWith => _$QuizCopyWithImpl<Quiz>(this as Quiz, _$identity);

  /// Serializes this Quiz to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quiz&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.timeLimit, timeLimit) || other.timeLimit == timeLimit)&&(identical(other.published, published) || other.published == published)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore)&&const DeepCollectionEquality().equals(other.questions, questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,moduleId,title,description,timeLimit,published,totalPoints,accessibilityScore,const DeepCollectionEquality().hash(questions));

@override
String toString() {
  return 'Quiz(id: $id, courseId: $courseId, moduleId: $moduleId, title: $title, description: $description, timeLimit: $timeLimit, published: $published, totalPoints: $totalPoints, accessibilityScore: $accessibilityScore, questions: $questions)';
}


}

/// @nodoc
abstract mixin class $QuizCopyWith<$Res>  {
  factory $QuizCopyWith(Quiz value, $Res Function(Quiz) _then) = _$QuizCopyWithImpl;
@useResult
$Res call({
 String id, String courseId, String? moduleId, String title, String description, int timeLimit, bool published, int totalPoints, int? accessibilityScore, List<QuizQuestion> questions
});




}
/// @nodoc
class _$QuizCopyWithImpl<$Res>
    implements $QuizCopyWith<$Res> {
  _$QuizCopyWithImpl(this._self, this._then);

  final Quiz _self;
  final $Res Function(Quiz) _then;

/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courseId = null,Object? moduleId = freezed,Object? title = null,Object? description = null,Object? timeLimit = null,Object? published = null,Object? totalPoints = null,Object? accessibilityScore = freezed,Object? questions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,timeLimit: null == timeLimit ? _self.timeLimit : timeLimit // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as bool,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,accessibilityScore: freezed == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int?,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<QuizQuestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [Quiz].
extension QuizPatterns on Quiz {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quiz value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quiz() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quiz value)  $default,){
final _that = this;
switch (_that) {
case _Quiz():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quiz value)?  $default,){
final _that = this;
switch (_that) {
case _Quiz() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String courseId,  String? moduleId,  String title,  String description,  int timeLimit,  bool published,  int totalPoints,  int? accessibilityScore,  List<QuizQuestion> questions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quiz() when $default != null:
return $default(_that.id,_that.courseId,_that.moduleId,_that.title,_that.description,_that.timeLimit,_that.published,_that.totalPoints,_that.accessibilityScore,_that.questions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String courseId,  String? moduleId,  String title,  String description,  int timeLimit,  bool published,  int totalPoints,  int? accessibilityScore,  List<QuizQuestion> questions)  $default,) {final _that = this;
switch (_that) {
case _Quiz():
return $default(_that.id,_that.courseId,_that.moduleId,_that.title,_that.description,_that.timeLimit,_that.published,_that.totalPoints,_that.accessibilityScore,_that.questions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String courseId,  String? moduleId,  String title,  String description,  int timeLimit,  bool published,  int totalPoints,  int? accessibilityScore,  List<QuizQuestion> questions)?  $default,) {final _that = this;
switch (_that) {
case _Quiz() when $default != null:
return $default(_that.id,_that.courseId,_that.moduleId,_that.title,_that.description,_that.timeLimit,_that.published,_that.totalPoints,_that.accessibilityScore,_that.questions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Quiz implements Quiz {
  const _Quiz({required this.id, required this.courseId, this.moduleId, required this.title, required this.description, this.timeLimit = 0, this.published = false, this.totalPoints = 0, this.accessibilityScore, required final  List<QuizQuestion> questions}): _questions = questions;
  factory _Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

@override final  String id;
@override final  String courseId;
@override final  String? moduleId;
@override final  String title;
@override final  String description;
@override@JsonKey() final  int timeLimit;
@override@JsonKey() final  bool published;
@override@JsonKey() final  int totalPoints;
@override final  int? accessibilityScore;
 final  List<QuizQuestion> _questions;
@override List<QuizQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}


/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizCopyWith<_Quiz> get copyWith => __$QuizCopyWithImpl<_Quiz>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuizToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quiz&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.timeLimit, timeLimit) || other.timeLimit == timeLimit)&&(identical(other.published, published) || other.published == published)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore)&&const DeepCollectionEquality().equals(other._questions, _questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,moduleId,title,description,timeLimit,published,totalPoints,accessibilityScore,const DeepCollectionEquality().hash(_questions));

@override
String toString() {
  return 'Quiz(id: $id, courseId: $courseId, moduleId: $moduleId, title: $title, description: $description, timeLimit: $timeLimit, published: $published, totalPoints: $totalPoints, accessibilityScore: $accessibilityScore, questions: $questions)';
}


}

/// @nodoc
abstract mixin class _$QuizCopyWith<$Res> implements $QuizCopyWith<$Res> {
  factory _$QuizCopyWith(_Quiz value, $Res Function(_Quiz) _then) = __$QuizCopyWithImpl;
@override @useResult
$Res call({
 String id, String courseId, String? moduleId, String title, String description, int timeLimit, bool published, int totalPoints, int? accessibilityScore, List<QuizQuestion> questions
});




}
/// @nodoc
class __$QuizCopyWithImpl<$Res>
    implements _$QuizCopyWith<$Res> {
  __$QuizCopyWithImpl(this._self, this._then);

  final _Quiz _self;
  final $Res Function(_Quiz) _then;

/// Create a copy of Quiz
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courseId = null,Object? moduleId = freezed,Object? title = null,Object? description = null,Object? timeLimit = null,Object? published = null,Object? totalPoints = null,Object? accessibilityScore = freezed,Object? questions = null,}) {
  return _then(_Quiz(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,moduleId: freezed == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,timeLimit: null == timeLimit ? _self.timeLimit : timeLimit // ignore: cast_nullable_to_non_nullable
as int,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as bool,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,accessibilityScore: freezed == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int?,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<QuizQuestion>,
  ));
}


}

// dart format on
