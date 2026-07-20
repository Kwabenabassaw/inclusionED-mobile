// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserHighlight {

 String get id; String get lessonId; String get courseId; String get text; int get startIndex; int get endIndex; String get colorHex; String? get note; DateTime get createdAt;
/// Create a copy of UserHighlight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserHighlightCopyWith<UserHighlight> get copyWith => _$UserHighlightCopyWithImpl<UserHighlight>(this as UserHighlight, _$identity);

  /// Serializes this UserHighlight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserHighlight&&(identical(other.id, id) || other.id == id)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.text, text) || other.text == text)&&(identical(other.startIndex, startIndex) || other.startIndex == startIndex)&&(identical(other.endIndex, endIndex) || other.endIndex == endIndex)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lessonId,courseId,text,startIndex,endIndex,colorHex,note,createdAt);

@override
String toString() {
  return 'UserHighlight(id: $id, lessonId: $lessonId, courseId: $courseId, text: $text, startIndex: $startIndex, endIndex: $endIndex, colorHex: $colorHex, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserHighlightCopyWith<$Res>  {
  factory $UserHighlightCopyWith(UserHighlight value, $Res Function(UserHighlight) _then) = _$UserHighlightCopyWithImpl;
@useResult
$Res call({
 String id, String lessonId, String courseId, String text, int startIndex, int endIndex, String colorHex, String? note, DateTime createdAt
});




}
/// @nodoc
class _$UserHighlightCopyWithImpl<$Res>
    implements $UserHighlightCopyWith<$Res> {
  _$UserHighlightCopyWithImpl(this._self, this._then);

  final UserHighlight _self;
  final $Res Function(UserHighlight) _then;

/// Create a copy of UserHighlight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lessonId = null,Object? courseId = null,Object? text = null,Object? startIndex = null,Object? endIndex = null,Object? colorHex = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,startIndex: null == startIndex ? _self.startIndex : startIndex // ignore: cast_nullable_to_non_nullable
as int,endIndex: null == endIndex ? _self.endIndex : endIndex // ignore: cast_nullable_to_non_nullable
as int,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserHighlight].
extension UserHighlightPatterns on UserHighlight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserHighlight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserHighlight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserHighlight value)  $default,){
final _that = this;
switch (_that) {
case _UserHighlight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserHighlight value)?  $default,){
final _that = this;
switch (_that) {
case _UserHighlight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lessonId,  String courseId,  String text,  int startIndex,  int endIndex,  String colorHex,  String? note,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserHighlight() when $default != null:
return $default(_that.id,_that.lessonId,_that.courseId,_that.text,_that.startIndex,_that.endIndex,_that.colorHex,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lessonId,  String courseId,  String text,  int startIndex,  int endIndex,  String colorHex,  String? note,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserHighlight():
return $default(_that.id,_that.lessonId,_that.courseId,_that.text,_that.startIndex,_that.endIndex,_that.colorHex,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lessonId,  String courseId,  String text,  int startIndex,  int endIndex,  String colorHex,  String? note,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserHighlight() when $default != null:
return $default(_that.id,_that.lessonId,_that.courseId,_that.text,_that.startIndex,_that.endIndex,_that.colorHex,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserHighlight implements UserHighlight {
  const _UserHighlight({required this.id, required this.lessonId, required this.courseId, required this.text, required this.startIndex, required this.endIndex, required this.colorHex, this.note, required this.createdAt});
  factory _UserHighlight.fromJson(Map<String, dynamic> json) => _$UserHighlightFromJson(json);

@override final  String id;
@override final  String lessonId;
@override final  String courseId;
@override final  String text;
@override final  int startIndex;
@override final  int endIndex;
@override final  String colorHex;
@override final  String? note;
@override final  DateTime createdAt;

/// Create a copy of UserHighlight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserHighlightCopyWith<_UserHighlight> get copyWith => __$UserHighlightCopyWithImpl<_UserHighlight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserHighlightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserHighlight&&(identical(other.id, id) || other.id == id)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.text, text) || other.text == text)&&(identical(other.startIndex, startIndex) || other.startIndex == startIndex)&&(identical(other.endIndex, endIndex) || other.endIndex == endIndex)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lessonId,courseId,text,startIndex,endIndex,colorHex,note,createdAt);

@override
String toString() {
  return 'UserHighlight(id: $id, lessonId: $lessonId, courseId: $courseId, text: $text, startIndex: $startIndex, endIndex: $endIndex, colorHex: $colorHex, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserHighlightCopyWith<$Res> implements $UserHighlightCopyWith<$Res> {
  factory _$UserHighlightCopyWith(_UserHighlight value, $Res Function(_UserHighlight) _then) = __$UserHighlightCopyWithImpl;
@override @useResult
$Res call({
 String id, String lessonId, String courseId, String text, int startIndex, int endIndex, String colorHex, String? note, DateTime createdAt
});




}
/// @nodoc
class __$UserHighlightCopyWithImpl<$Res>
    implements _$UserHighlightCopyWith<$Res> {
  __$UserHighlightCopyWithImpl(this._self, this._then);

  final _UserHighlight _self;
  final $Res Function(_UserHighlight) _then;

/// Create a copy of UserHighlight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lessonId = null,Object? courseId = null,Object? text = null,Object? startIndex = null,Object? endIndex = null,Object? colorHex = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_UserHighlight(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,startIndex: null == startIndex ? _self.startIndex : startIndex // ignore: cast_nullable_to_non_nullable
as int,endIndex: null == endIndex ? _self.endIndex : endIndex // ignore: cast_nullable_to_non_nullable
as int,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserNote {

 String get id; String get lessonId; String get courseId; String get title; String get content; String? get anchoredText; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of UserNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserNoteCopyWith<UserNote> get copyWith => _$UserNoteCopyWithImpl<UserNote>(this as UserNote, _$identity);

  /// Serializes this UserNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserNote&&(identical(other.id, id) || other.id == id)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.anchoredText, anchoredText) || other.anchoredText == anchoredText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lessonId,courseId,title,content,anchoredText,createdAt,updatedAt);

@override
String toString() {
  return 'UserNote(id: $id, lessonId: $lessonId, courseId: $courseId, title: $title, content: $content, anchoredText: $anchoredText, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserNoteCopyWith<$Res>  {
  factory $UserNoteCopyWith(UserNote value, $Res Function(UserNote) _then) = _$UserNoteCopyWithImpl;
@useResult
$Res call({
 String id, String lessonId, String courseId, String title, String content, String? anchoredText, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$UserNoteCopyWithImpl<$Res>
    implements $UserNoteCopyWith<$Res> {
  _$UserNoteCopyWithImpl(this._self, this._then);

  final UserNote _self;
  final $Res Function(UserNote) _then;

/// Create a copy of UserNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lessonId = null,Object? courseId = null,Object? title = null,Object? content = null,Object? anchoredText = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,anchoredText: freezed == anchoredText ? _self.anchoredText : anchoredText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserNote].
extension UserNotePatterns on UserNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserNote value)  $default,){
final _that = this;
switch (_that) {
case _UserNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserNote value)?  $default,){
final _that = this;
switch (_that) {
case _UserNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lessonId,  String courseId,  String title,  String content,  String? anchoredText,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserNote() when $default != null:
return $default(_that.id,_that.lessonId,_that.courseId,_that.title,_that.content,_that.anchoredText,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lessonId,  String courseId,  String title,  String content,  String? anchoredText,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserNote():
return $default(_that.id,_that.lessonId,_that.courseId,_that.title,_that.content,_that.anchoredText,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lessonId,  String courseId,  String title,  String content,  String? anchoredText,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserNote() when $default != null:
return $default(_that.id,_that.lessonId,_that.courseId,_that.title,_that.content,_that.anchoredText,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserNote implements UserNote {
  const _UserNote({required this.id, required this.lessonId, required this.courseId, required this.title, required this.content, this.anchoredText, required this.createdAt, required this.updatedAt});
  factory _UserNote.fromJson(Map<String, dynamic> json) => _$UserNoteFromJson(json);

@override final  String id;
@override final  String lessonId;
@override final  String courseId;
@override final  String title;
@override final  String content;
@override final  String? anchoredText;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of UserNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserNoteCopyWith<_UserNote> get copyWith => __$UserNoteCopyWithImpl<_UserNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserNote&&(identical(other.id, id) || other.id == id)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.anchoredText, anchoredText) || other.anchoredText == anchoredText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lessonId,courseId,title,content,anchoredText,createdAt,updatedAt);

@override
String toString() {
  return 'UserNote(id: $id, lessonId: $lessonId, courseId: $courseId, title: $title, content: $content, anchoredText: $anchoredText, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserNoteCopyWith<$Res> implements $UserNoteCopyWith<$Res> {
  factory _$UserNoteCopyWith(_UserNote value, $Res Function(_UserNote) _then) = __$UserNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String lessonId, String courseId, String title, String content, String? anchoredText, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$UserNoteCopyWithImpl<$Res>
    implements _$UserNoteCopyWith<$Res> {
  __$UserNoteCopyWithImpl(this._self, this._then);

  final _UserNote _self;
  final $Res Function(_UserNote) _then;

/// Create a copy of UserNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lessonId = null,Object? courseId = null,Object? title = null,Object? content = null,Object? anchoredText = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,anchoredText: freezed == anchoredText ? _self.anchoredText : anchoredText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserFlashcard {

 String get id; String get lessonId; String get courseId; String get question; String get answer; String get category; int get masteryLevel; DateTime? get nextReviewDate; DateTime get createdAt;
/// Create a copy of UserFlashcard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFlashcardCopyWith<UserFlashcard> get copyWith => _$UserFlashcardCopyWithImpl<UserFlashcard>(this as UserFlashcard, _$identity);

  /// Serializes this UserFlashcard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFlashcard&&(identical(other.id, id) || other.id == id)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.category, category) || other.category == category)&&(identical(other.masteryLevel, masteryLevel) || other.masteryLevel == masteryLevel)&&(identical(other.nextReviewDate, nextReviewDate) || other.nextReviewDate == nextReviewDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lessonId,courseId,question,answer,category,masteryLevel,nextReviewDate,createdAt);

@override
String toString() {
  return 'UserFlashcard(id: $id, lessonId: $lessonId, courseId: $courseId, question: $question, answer: $answer, category: $category, masteryLevel: $masteryLevel, nextReviewDate: $nextReviewDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserFlashcardCopyWith<$Res>  {
  factory $UserFlashcardCopyWith(UserFlashcard value, $Res Function(UserFlashcard) _then) = _$UserFlashcardCopyWithImpl;
@useResult
$Res call({
 String id, String lessonId, String courseId, String question, String answer, String category, int masteryLevel, DateTime? nextReviewDate, DateTime createdAt
});




}
/// @nodoc
class _$UserFlashcardCopyWithImpl<$Res>
    implements $UserFlashcardCopyWith<$Res> {
  _$UserFlashcardCopyWithImpl(this._self, this._then);

  final UserFlashcard _self;
  final $Res Function(UserFlashcard) _then;

/// Create a copy of UserFlashcard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lessonId = null,Object? courseId = null,Object? question = null,Object? answer = null,Object? category = null,Object? masteryLevel = null,Object? nextReviewDate = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,masteryLevel: null == masteryLevel ? _self.masteryLevel : masteryLevel // ignore: cast_nullable_to_non_nullable
as int,nextReviewDate: freezed == nextReviewDate ? _self.nextReviewDate : nextReviewDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFlashcard].
extension UserFlashcardPatterns on UserFlashcard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFlashcard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFlashcard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFlashcard value)  $default,){
final _that = this;
switch (_that) {
case _UserFlashcard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFlashcard value)?  $default,){
final _that = this;
switch (_that) {
case _UserFlashcard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lessonId,  String courseId,  String question,  String answer,  String category,  int masteryLevel,  DateTime? nextReviewDate,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFlashcard() when $default != null:
return $default(_that.id,_that.lessonId,_that.courseId,_that.question,_that.answer,_that.category,_that.masteryLevel,_that.nextReviewDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lessonId,  String courseId,  String question,  String answer,  String category,  int masteryLevel,  DateTime? nextReviewDate,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserFlashcard():
return $default(_that.id,_that.lessonId,_that.courseId,_that.question,_that.answer,_that.category,_that.masteryLevel,_that.nextReviewDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lessonId,  String courseId,  String question,  String answer,  String category,  int masteryLevel,  DateTime? nextReviewDate,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserFlashcard() when $default != null:
return $default(_that.id,_that.lessonId,_that.courseId,_that.question,_that.answer,_that.category,_that.masteryLevel,_that.nextReviewDate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserFlashcard implements UserFlashcard {
  const _UserFlashcard({required this.id, required this.lessonId, required this.courseId, required this.question, required this.answer, required this.category, required this.masteryLevel, this.nextReviewDate, required this.createdAt});
  factory _UserFlashcard.fromJson(Map<String, dynamic> json) => _$UserFlashcardFromJson(json);

@override final  String id;
@override final  String lessonId;
@override final  String courseId;
@override final  String question;
@override final  String answer;
@override final  String category;
@override final  int masteryLevel;
@override final  DateTime? nextReviewDate;
@override final  DateTime createdAt;

/// Create a copy of UserFlashcard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFlashcardCopyWith<_UserFlashcard> get copyWith => __$UserFlashcardCopyWithImpl<_UserFlashcard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserFlashcardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFlashcard&&(identical(other.id, id) || other.id == id)&&(identical(other.lessonId, lessonId) || other.lessonId == lessonId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.question, question) || other.question == question)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.category, category) || other.category == category)&&(identical(other.masteryLevel, masteryLevel) || other.masteryLevel == masteryLevel)&&(identical(other.nextReviewDate, nextReviewDate) || other.nextReviewDate == nextReviewDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lessonId,courseId,question,answer,category,masteryLevel,nextReviewDate,createdAt);

@override
String toString() {
  return 'UserFlashcard(id: $id, lessonId: $lessonId, courseId: $courseId, question: $question, answer: $answer, category: $category, masteryLevel: $masteryLevel, nextReviewDate: $nextReviewDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserFlashcardCopyWith<$Res> implements $UserFlashcardCopyWith<$Res> {
  factory _$UserFlashcardCopyWith(_UserFlashcard value, $Res Function(_UserFlashcard) _then) = __$UserFlashcardCopyWithImpl;
@override @useResult
$Res call({
 String id, String lessonId, String courseId, String question, String answer, String category, int masteryLevel, DateTime? nextReviewDate, DateTime createdAt
});




}
/// @nodoc
class __$UserFlashcardCopyWithImpl<$Res>
    implements _$UserFlashcardCopyWith<$Res> {
  __$UserFlashcardCopyWithImpl(this._self, this._then);

  final _UserFlashcard _self;
  final $Res Function(_UserFlashcard) _then;

/// Create a copy of UserFlashcard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lessonId = null,Object? courseId = null,Object? question = null,Object? answer = null,Object? category = null,Object? masteryLevel = null,Object? nextReviewDate = freezed,Object? createdAt = null,}) {
  return _then(_UserFlashcard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lessonId: null == lessonId ? _self.lessonId : lessonId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,question: null == question ? _self.question : question // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,masteryLevel: null == masteryLevel ? _self.masteryLevel : masteryLevel // ignore: cast_nullable_to_non_nullable
as int,nextReviewDate: freezed == nextReviewDate ? _self.nextReviewDate : nextReviewDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
