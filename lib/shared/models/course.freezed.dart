// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Course {

 String get id; String get code; String get name; String get description; String get department; String get level; String get term; bool get published; bool get archived; int get studentsCount; int get accessibilityScore; String get createdAt; String get instructorId; String? get imageUrl;
/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseCopyWith<Course> get copyWith => _$CourseCopyWithImpl<Course>(this as Course, _$identity);

  /// Serializes this Course to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Course&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.department, department) || other.department == department)&&(identical(other.level, level) || other.level == level)&&(identical(other.term, term) || other.term == term)&&(identical(other.published, published) || other.published == published)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.studentsCount, studentsCount) || other.studentsCount == studentsCount)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.instructorId, instructorId) || other.instructorId == instructorId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,description,department,level,term,published,archived,studentsCount,accessibilityScore,createdAt,instructorId,imageUrl);

@override
String toString() {
  return 'Course(id: $id, code: $code, name: $name, description: $description, department: $department, level: $level, term: $term, published: $published, archived: $archived, studentsCount: $studentsCount, accessibilityScore: $accessibilityScore, createdAt: $createdAt, instructorId: $instructorId, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $CourseCopyWith<$Res>  {
  factory $CourseCopyWith(Course value, $Res Function(Course) _then) = _$CourseCopyWithImpl;
@useResult
$Res call({
 String id, String code, String name, String description, String department, String level, String term, bool published, bool archived, int studentsCount, int accessibilityScore, String createdAt, String instructorId, String? imageUrl
});




}
/// @nodoc
class _$CourseCopyWithImpl<$Res>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._self, this._then);

  final Course _self;
  final $Res Function(Course) _then;

/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = null,Object? department = null,Object? level = null,Object? term = null,Object? published = null,Object? archived = null,Object? studentsCount = null,Object? accessibilityScore = null,Object? createdAt = null,Object? instructorId = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,studentsCount: null == studentsCount ? _self.studentsCount : studentsCount // ignore: cast_nullable_to_non_nullable
as int,accessibilityScore: null == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,instructorId: null == instructorId ? _self.instructorId : instructorId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Course].
extension CoursePatterns on Course {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Course value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Course() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Course value)  $default,){
final _that = this;
switch (_that) {
case _Course():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Course value)?  $default,){
final _that = this;
switch (_that) {
case _Course() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String description,  String department,  String level,  String term,  bool published,  bool archived,  int studentsCount,  int accessibilityScore,  String createdAt,  String instructorId,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Course() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.department,_that.level,_that.term,_that.published,_that.archived,_that.studentsCount,_that.accessibilityScore,_that.createdAt,_that.instructorId,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String name,  String description,  String department,  String level,  String term,  bool published,  bool archived,  int studentsCount,  int accessibilityScore,  String createdAt,  String instructorId,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Course():
return $default(_that.id,_that.code,_that.name,_that.description,_that.department,_that.level,_that.term,_that.published,_that.archived,_that.studentsCount,_that.accessibilityScore,_that.createdAt,_that.instructorId,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String name,  String description,  String department,  String level,  String term,  bool published,  bool archived,  int studentsCount,  int accessibilityScore,  String createdAt,  String instructorId,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Course() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.description,_that.department,_that.level,_that.term,_that.published,_that.archived,_that.studentsCount,_that.accessibilityScore,_that.createdAt,_that.instructorId,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Course implements Course {
  const _Course({required this.id, required this.code, required this.name, required this.description, required this.department, required this.level, required this.term, required this.published, required this.archived, this.studentsCount = 0, this.accessibilityScore = 0, required this.createdAt, required this.instructorId, this.imageUrl});
  factory _Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

@override final  String id;
@override final  String code;
@override final  String name;
@override final  String description;
@override final  String department;
@override final  String level;
@override final  String term;
@override final  bool published;
@override final  bool archived;
@override@JsonKey() final  int studentsCount;
@override@JsonKey() final  int accessibilityScore;
@override final  String createdAt;
@override final  String instructorId;
@override final  String? imageUrl;

/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseCopyWith<_Course> get copyWith => __$CourseCopyWithImpl<_Course>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Course&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.department, department) || other.department == department)&&(identical(other.level, level) || other.level == level)&&(identical(other.term, term) || other.term == term)&&(identical(other.published, published) || other.published == published)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.studentsCount, studentsCount) || other.studentsCount == studentsCount)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.instructorId, instructorId) || other.instructorId == instructorId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,description,department,level,term,published,archived,studentsCount,accessibilityScore,createdAt,instructorId,imageUrl);

@override
String toString() {
  return 'Course(id: $id, code: $code, name: $name, description: $description, department: $department, level: $level, term: $term, published: $published, archived: $archived, studentsCount: $studentsCount, accessibilityScore: $accessibilityScore, createdAt: $createdAt, instructorId: $instructorId, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$CourseCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$CourseCopyWith(_Course value, $Res Function(_Course) _then) = __$CourseCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String name, String description, String department, String level, String term, bool published, bool archived, int studentsCount, int accessibilityScore, String createdAt, String instructorId, String? imageUrl
});




}
/// @nodoc
class __$CourseCopyWithImpl<$Res>
    implements _$CourseCopyWith<$Res> {
  __$CourseCopyWithImpl(this._self, this._then);

  final _Course _self;
  final $Res Function(_Course) _then;

/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? description = null,Object? department = null,Object? level = null,Object? term = null,Object? published = null,Object? archived = null,Object? studentsCount = null,Object? accessibilityScore = null,Object? createdAt = null,Object? instructorId = null,Object? imageUrl = freezed,}) {
  return _then(_Course(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,published: null == published ? _self.published : published // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,studentsCount: null == studentsCount ? _self.studentsCount : studentsCount // ignore: cast_nullable_to_non_nullable
as int,accessibilityScore: null == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,instructorId: null == instructorId ? _self.instructorId : instructorId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
