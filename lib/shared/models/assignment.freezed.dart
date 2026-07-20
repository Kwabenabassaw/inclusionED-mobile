// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Assignment {

 String get id; String get courseId; String get title; String get description; String get dueDate; int get totalPoints; List<Map<String, dynamic>> get attachments; bool get isPublished; String get createdAt;
/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignmentCopyWith<Assignment> get copyWith => _$AssignmentCopyWithImpl<Assignment>(this as Assignment, _$identity);

  /// Serializes this Assignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Assignment&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,title,description,dueDate,totalPoints,const DeepCollectionEquality().hash(attachments),isPublished,createdAt);

@override
String toString() {
  return 'Assignment(id: $id, courseId: $courseId, title: $title, description: $description, dueDate: $dueDate, totalPoints: $totalPoints, attachments: $attachments, isPublished: $isPublished, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AssignmentCopyWith<$Res>  {
  factory $AssignmentCopyWith(Assignment value, $Res Function(Assignment) _then) = _$AssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String courseId, String title, String description, String dueDate, int totalPoints, List<Map<String, dynamic>> attachments, bool isPublished, String createdAt
});




}
/// @nodoc
class _$AssignmentCopyWithImpl<$Res>
    implements $AssignmentCopyWith<$Res> {
  _$AssignmentCopyWithImpl(this._self, this._then);

  final Assignment _self;
  final $Res Function(Assignment) _then;

/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courseId = null,Object? title = null,Object? description = null,Object? dueDate = null,Object? totalPoints = null,Object? attachments = null,Object? isPublished = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Assignment].
extension AssignmentPatterns on Assignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Assignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Assignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Assignment value)  $default,){
final _that = this;
switch (_that) {
case _Assignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Assignment value)?  $default,){
final _that = this;
switch (_that) {
case _Assignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String courseId,  String title,  String description,  String dueDate,  int totalPoints,  List<Map<String, dynamic>> attachments,  bool isPublished,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Assignment() when $default != null:
return $default(_that.id,_that.courseId,_that.title,_that.description,_that.dueDate,_that.totalPoints,_that.attachments,_that.isPublished,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String courseId,  String title,  String description,  String dueDate,  int totalPoints,  List<Map<String, dynamic>> attachments,  bool isPublished,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _Assignment():
return $default(_that.id,_that.courseId,_that.title,_that.description,_that.dueDate,_that.totalPoints,_that.attachments,_that.isPublished,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String courseId,  String title,  String description,  String dueDate,  int totalPoints,  List<Map<String, dynamic>> attachments,  bool isPublished,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Assignment() when $default != null:
return $default(_that.id,_that.courseId,_that.title,_that.description,_that.dueDate,_that.totalPoints,_that.attachments,_that.isPublished,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Assignment implements Assignment {
  const _Assignment({required this.id, required this.courseId, required this.title, required this.description, required this.dueDate, required this.totalPoints, final  List<Map<String, dynamic>> attachments = const [], this.isPublished = false, required this.createdAt}): _attachments = attachments;
  factory _Assignment.fromJson(Map<String, dynamic> json) => _$AssignmentFromJson(json);

@override final  String id;
@override final  String courseId;
@override final  String title;
@override final  String description;
@override final  String dueDate;
@override final  int totalPoints;
 final  List<Map<String, dynamic>> _attachments;
@override@JsonKey() List<Map<String, dynamic>> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override@JsonKey() final  bool isPublished;
@override final  String createdAt;

/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignmentCopyWith<_Assignment> get copyWith => __$AssignmentCopyWithImpl<_Assignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Assignment&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,title,description,dueDate,totalPoints,const DeepCollectionEquality().hash(_attachments),isPublished,createdAt);

@override
String toString() {
  return 'Assignment(id: $id, courseId: $courseId, title: $title, description: $description, dueDate: $dueDate, totalPoints: $totalPoints, attachments: $attachments, isPublished: $isPublished, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AssignmentCopyWith<$Res> implements $AssignmentCopyWith<$Res> {
  factory _$AssignmentCopyWith(_Assignment value, $Res Function(_Assignment) _then) = __$AssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String courseId, String title, String description, String dueDate, int totalPoints, List<Map<String, dynamic>> attachments, bool isPublished, String createdAt
});




}
/// @nodoc
class __$AssignmentCopyWithImpl<$Res>
    implements _$AssignmentCopyWith<$Res> {
  __$AssignmentCopyWithImpl(this._self, this._then);

  final _Assignment _self;
  final $Res Function(_Assignment) _then;

/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courseId = null,Object? title = null,Object? description = null,Object? dueDate = null,Object? totalPoints = null,Object? attachments = null,Object? isPublished = null,Object? createdAt = null,}) {
  return _then(_Assignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AssignmentSubmission {

 String get id; String get assignmentId; String get studentId; String get status; String get submittedFileUrl; String get submittedFileName; String get submittedAt; int? get grade; String? get feedback; String? get gradedBy; String? get gradedAt;
/// Create a copy of AssignmentSubmission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignmentSubmissionCopyWith<AssignmentSubmission> get copyWith => _$AssignmentSubmissionCopyWithImpl<AssignmentSubmission>(this as AssignmentSubmission, _$identity);

  /// Serializes this AssignmentSubmission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignmentSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedFileUrl, submittedFileUrl) || other.submittedFileUrl == submittedFileUrl)&&(identical(other.submittedFileName, submittedFileName) || other.submittedFileName == submittedFileName)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.gradedBy, gradedBy) || other.gradedBy == gradedBy)&&(identical(other.gradedAt, gradedAt) || other.gradedAt == gradedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assignmentId,studentId,status,submittedFileUrl,submittedFileName,submittedAt,grade,feedback,gradedBy,gradedAt);

@override
String toString() {
  return 'AssignmentSubmission(id: $id, assignmentId: $assignmentId, studentId: $studentId, status: $status, submittedFileUrl: $submittedFileUrl, submittedFileName: $submittedFileName, submittedAt: $submittedAt, grade: $grade, feedback: $feedback, gradedBy: $gradedBy, gradedAt: $gradedAt)';
}


}

/// @nodoc
abstract mixin class $AssignmentSubmissionCopyWith<$Res>  {
  factory $AssignmentSubmissionCopyWith(AssignmentSubmission value, $Res Function(AssignmentSubmission) _then) = _$AssignmentSubmissionCopyWithImpl;
@useResult
$Res call({
 String id, String assignmentId, String studentId, String status, String submittedFileUrl, String submittedFileName, String submittedAt, int? grade, String? feedback, String? gradedBy, String? gradedAt
});




}
/// @nodoc
class _$AssignmentSubmissionCopyWithImpl<$Res>
    implements $AssignmentSubmissionCopyWith<$Res> {
  _$AssignmentSubmissionCopyWithImpl(this._self, this._then);

  final AssignmentSubmission _self;
  final $Res Function(AssignmentSubmission) _then;

/// Create a copy of AssignmentSubmission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assignmentId = null,Object? studentId = null,Object? status = null,Object? submittedFileUrl = null,Object? submittedFileName = null,Object? submittedAt = null,Object? grade = freezed,Object? feedback = freezed,Object? gradedBy = freezed,Object? gradedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedFileUrl: null == submittedFileUrl ? _self.submittedFileUrl : submittedFileUrl // ignore: cast_nullable_to_non_nullable
as String,submittedFileName: null == submittedFileName ? _self.submittedFileName : submittedFileName // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,gradedBy: freezed == gradedBy ? _self.gradedBy : gradedBy // ignore: cast_nullable_to_non_nullable
as String?,gradedAt: freezed == gradedAt ? _self.gradedAt : gradedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignmentSubmission].
extension AssignmentSubmissionPatterns on AssignmentSubmission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignmentSubmission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignmentSubmission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignmentSubmission value)  $default,){
final _that = this;
switch (_that) {
case _AssignmentSubmission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignmentSubmission value)?  $default,){
final _that = this;
switch (_that) {
case _AssignmentSubmission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String assignmentId,  String studentId,  String status,  String submittedFileUrl,  String submittedFileName,  String submittedAt,  int? grade,  String? feedback,  String? gradedBy,  String? gradedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignmentSubmission() when $default != null:
return $default(_that.id,_that.assignmentId,_that.studentId,_that.status,_that.submittedFileUrl,_that.submittedFileName,_that.submittedAt,_that.grade,_that.feedback,_that.gradedBy,_that.gradedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String assignmentId,  String studentId,  String status,  String submittedFileUrl,  String submittedFileName,  String submittedAt,  int? grade,  String? feedback,  String? gradedBy,  String? gradedAt)  $default,) {final _that = this;
switch (_that) {
case _AssignmentSubmission():
return $default(_that.id,_that.assignmentId,_that.studentId,_that.status,_that.submittedFileUrl,_that.submittedFileName,_that.submittedAt,_that.grade,_that.feedback,_that.gradedBy,_that.gradedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String assignmentId,  String studentId,  String status,  String submittedFileUrl,  String submittedFileName,  String submittedAt,  int? grade,  String? feedback,  String? gradedBy,  String? gradedAt)?  $default,) {final _that = this;
switch (_that) {
case _AssignmentSubmission() when $default != null:
return $default(_that.id,_that.assignmentId,_that.studentId,_that.status,_that.submittedFileUrl,_that.submittedFileName,_that.submittedAt,_that.grade,_that.feedback,_that.gradedBy,_that.gradedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignmentSubmission implements AssignmentSubmission {
  const _AssignmentSubmission({required this.id, required this.assignmentId, required this.studentId, required this.status, required this.submittedFileUrl, required this.submittedFileName, required this.submittedAt, this.grade, this.feedback, this.gradedBy, this.gradedAt});
  factory _AssignmentSubmission.fromJson(Map<String, dynamic> json) => _$AssignmentSubmissionFromJson(json);

@override final  String id;
@override final  String assignmentId;
@override final  String studentId;
@override final  String status;
@override final  String submittedFileUrl;
@override final  String submittedFileName;
@override final  String submittedAt;
@override final  int? grade;
@override final  String? feedback;
@override final  String? gradedBy;
@override final  String? gradedAt;

/// Create a copy of AssignmentSubmission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignmentSubmissionCopyWith<_AssignmentSubmission> get copyWith => __$AssignmentSubmissionCopyWithImpl<_AssignmentSubmission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignmentSubmissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignmentSubmission&&(identical(other.id, id) || other.id == id)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedFileUrl, submittedFileUrl) || other.submittedFileUrl == submittedFileUrl)&&(identical(other.submittedFileName, submittedFileName) || other.submittedFileName == submittedFileName)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.gradedBy, gradedBy) || other.gradedBy == gradedBy)&&(identical(other.gradedAt, gradedAt) || other.gradedAt == gradedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,assignmentId,studentId,status,submittedFileUrl,submittedFileName,submittedAt,grade,feedback,gradedBy,gradedAt);

@override
String toString() {
  return 'AssignmentSubmission(id: $id, assignmentId: $assignmentId, studentId: $studentId, status: $status, submittedFileUrl: $submittedFileUrl, submittedFileName: $submittedFileName, submittedAt: $submittedAt, grade: $grade, feedback: $feedback, gradedBy: $gradedBy, gradedAt: $gradedAt)';
}


}

/// @nodoc
abstract mixin class _$AssignmentSubmissionCopyWith<$Res> implements $AssignmentSubmissionCopyWith<$Res> {
  factory _$AssignmentSubmissionCopyWith(_AssignmentSubmission value, $Res Function(_AssignmentSubmission) _then) = __$AssignmentSubmissionCopyWithImpl;
@override @useResult
$Res call({
 String id, String assignmentId, String studentId, String status, String submittedFileUrl, String submittedFileName, String submittedAt, int? grade, String? feedback, String? gradedBy, String? gradedAt
});




}
/// @nodoc
class __$AssignmentSubmissionCopyWithImpl<$Res>
    implements _$AssignmentSubmissionCopyWith<$Res> {
  __$AssignmentSubmissionCopyWithImpl(this._self, this._then);

  final _AssignmentSubmission _self;
  final $Res Function(_AssignmentSubmission) _then;

/// Create a copy of AssignmentSubmission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assignmentId = null,Object? studentId = null,Object? status = null,Object? submittedFileUrl = null,Object? submittedFileName = null,Object? submittedAt = null,Object? grade = freezed,Object? feedback = freezed,Object? gradedBy = freezed,Object? gradedAt = freezed,}) {
  return _then(_AssignmentSubmission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assignmentId: null == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedFileUrl: null == submittedFileUrl ? _self.submittedFileUrl : submittedFileUrl // ignore: cast_nullable_to_non_nullable
as String,submittedFileName: null == submittedFileName ? _self.submittedFileName : submittedFileName // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as int?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,gradedBy: freezed == gradedBy ? _self.gradedBy : gradedBy // ignore: cast_nullable_to_non_nullable
as String?,gradedAt: freezed == gradedAt ? _self.gradedAt : gradedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
