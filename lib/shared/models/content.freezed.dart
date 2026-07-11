// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeneratedAltText {

 String get id; String get imageLabel; String get suggestedAlt;
/// Create a copy of GeneratedAltText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedAltTextCopyWith<GeneratedAltText> get copyWith => _$GeneratedAltTextCopyWithImpl<GeneratedAltText>(this as GeneratedAltText, _$identity);

  /// Serializes this GeneratedAltText to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedAltText&&(identical(other.id, id) || other.id == id)&&(identical(other.imageLabel, imageLabel) || other.imageLabel == imageLabel)&&(identical(other.suggestedAlt, suggestedAlt) || other.suggestedAlt == suggestedAlt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageLabel,suggestedAlt);

@override
String toString() {
  return 'GeneratedAltText(id: $id, imageLabel: $imageLabel, suggestedAlt: $suggestedAlt)';
}


}

/// @nodoc
abstract mixin class $GeneratedAltTextCopyWith<$Res>  {
  factory $GeneratedAltTextCopyWith(GeneratedAltText value, $Res Function(GeneratedAltText) _then) = _$GeneratedAltTextCopyWithImpl;
@useResult
$Res call({
 String id, String imageLabel, String suggestedAlt
});




}
/// @nodoc
class _$GeneratedAltTextCopyWithImpl<$Res>
    implements $GeneratedAltTextCopyWith<$Res> {
  _$GeneratedAltTextCopyWithImpl(this._self, this._then);

  final GeneratedAltText _self;
  final $Res Function(GeneratedAltText) _then;

/// Create a copy of GeneratedAltText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imageLabel = null,Object? suggestedAlt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageLabel: null == imageLabel ? _self.imageLabel : imageLabel // ignore: cast_nullable_to_non_nullable
as String,suggestedAlt: null == suggestedAlt ? _self.suggestedAlt : suggestedAlt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedAltText].
extension GeneratedAltTextPatterns on GeneratedAltText {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedAltText value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedAltText() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedAltText value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedAltText():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedAltText value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedAltText() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String imageLabel,  String suggestedAlt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedAltText() when $default != null:
return $default(_that.id,_that.imageLabel,_that.suggestedAlt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String imageLabel,  String suggestedAlt)  $default,) {final _that = this;
switch (_that) {
case _GeneratedAltText():
return $default(_that.id,_that.imageLabel,_that.suggestedAlt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String imageLabel,  String suggestedAlt)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedAltText() when $default != null:
return $default(_that.id,_that.imageLabel,_that.suggestedAlt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeneratedAltText implements GeneratedAltText {
  const _GeneratedAltText({required this.id, required this.imageLabel, required this.suggestedAlt});
  factory _GeneratedAltText.fromJson(Map<String, dynamic> json) => _$GeneratedAltTextFromJson(json);

@override final  String id;
@override final  String imageLabel;
@override final  String suggestedAlt;

/// Create a copy of GeneratedAltText
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedAltTextCopyWith<_GeneratedAltText> get copyWith => __$GeneratedAltTextCopyWithImpl<_GeneratedAltText>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeneratedAltTextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedAltText&&(identical(other.id, id) || other.id == id)&&(identical(other.imageLabel, imageLabel) || other.imageLabel == imageLabel)&&(identical(other.suggestedAlt, suggestedAlt) || other.suggestedAlt == suggestedAlt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageLabel,suggestedAlt);

@override
String toString() {
  return 'GeneratedAltText(id: $id, imageLabel: $imageLabel, suggestedAlt: $suggestedAlt)';
}


}

/// @nodoc
abstract mixin class _$GeneratedAltTextCopyWith<$Res> implements $GeneratedAltTextCopyWith<$Res> {
  factory _$GeneratedAltTextCopyWith(_GeneratedAltText value, $Res Function(_GeneratedAltText) _then) = __$GeneratedAltTextCopyWithImpl;
@override @useResult
$Res call({
 String id, String imageLabel, String suggestedAlt
});




}
/// @nodoc
class __$GeneratedAltTextCopyWithImpl<$Res>
    implements _$GeneratedAltTextCopyWith<$Res> {
  __$GeneratedAltTextCopyWithImpl(this._self, this._then);

  final _GeneratedAltText _self;
  final $Res Function(_GeneratedAltText) _then;

/// Create a copy of GeneratedAltText
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imageLabel = null,Object? suggestedAlt = null,}) {
  return _then(_GeneratedAltText(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imageLabel: null == imageLabel ? _self.imageLabel : imageLabel // ignore: cast_nullable_to_non_nullable
as String,suggestedAlt: null == suggestedAlt ? _self.suggestedAlt : suggestedAlt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ContentBlock {

 String get id; String get type; String? get title; dynamic get content; Map<String, dynamic>? get metadata; int get order;
/// Create a copy of ContentBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentBlockCopyWith<ContentBlock> get copyWith => _$ContentBlockCopyWithImpl<ContentBlock>(this as ContentBlock, _$identity);

  /// Serializes this ContentBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.content, content)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,const DeepCollectionEquality().hash(content),const DeepCollectionEquality().hash(metadata),order);

@override
String toString() {
  return 'ContentBlock(id: $id, type: $type, title: $title, content: $content, metadata: $metadata, order: $order)';
}


}

/// @nodoc
abstract mixin class $ContentBlockCopyWith<$Res>  {
  factory $ContentBlockCopyWith(ContentBlock value, $Res Function(ContentBlock) _then) = _$ContentBlockCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? title, dynamic content, Map<String, dynamic>? metadata, int order
});




}
/// @nodoc
class _$ContentBlockCopyWithImpl<$Res>
    implements $ContentBlockCopyWith<$Res> {
  _$ContentBlockCopyWithImpl(this._self, this._then);

  final ContentBlock _self;
  final $Res Function(ContentBlock) _then;

/// Create a copy of ContentBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? content = freezed,Object? metadata = freezed,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as dynamic,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentBlock].
extension ContentBlockPatterns on ContentBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentBlock value)  $default,){
final _that = this;
switch (_that) {
case _ContentBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentBlock value)?  $default,){
final _that = this;
switch (_that) {
case _ContentBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? title,  dynamic content,  Map<String, dynamic>? metadata,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentBlock() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.content,_that.metadata,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? title,  dynamic content,  Map<String, dynamic>? metadata,  int order)  $default,) {final _that = this;
switch (_that) {
case _ContentBlock():
return $default(_that.id,_that.type,_that.title,_that.content,_that.metadata,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? title,  dynamic content,  Map<String, dynamic>? metadata,  int order)?  $default,) {final _that = this;
switch (_that) {
case _ContentBlock() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.content,_that.metadata,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentBlock implements ContentBlock {
  const _ContentBlock({required this.id, required this.type, this.title, this.content, final  Map<String, dynamic>? metadata, required this.order}): _metadata = metadata;
  factory _ContentBlock.fromJson(Map<String, dynamic> json) => _$ContentBlockFromJson(json);

@override final  String id;
@override final  String type;
@override final  String? title;
@override final  dynamic content;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int order;

/// Create a copy of ContentBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentBlockCopyWith<_ContentBlock> get copyWith => __$ContentBlockCopyWithImpl<_ContentBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentBlock&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.content, content)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,const DeepCollectionEquality().hash(content),const DeepCollectionEquality().hash(_metadata),order);

@override
String toString() {
  return 'ContentBlock(id: $id, type: $type, title: $title, content: $content, metadata: $metadata, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ContentBlockCopyWith<$Res> implements $ContentBlockCopyWith<$Res> {
  factory _$ContentBlockCopyWith(_ContentBlock value, $Res Function(_ContentBlock) _then) = __$ContentBlockCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? title, dynamic content, Map<String, dynamic>? metadata, int order
});




}
/// @nodoc
class __$ContentBlockCopyWithImpl<$Res>
    implements _$ContentBlockCopyWith<$Res> {
  __$ContentBlockCopyWithImpl(this._self, this._then);

  final _ContentBlock _self;
  final $Res Function(_ContentBlock) _then;

/// Create a copy of ContentBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? content = freezed,Object? metadata = freezed,Object? order = null,}) {
  return _then(_ContentBlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as dynamic,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Content {

 String get id; String get courseId; String get moduleId; String get title; String get type; String? get text; String? get fileName; String? get fileUrl; String? get fileSize; String? get linkUrl; String get status; String? get contentMarkdown; List<GeneratedAltText>? get altTextsGenerated; int get accessibilityScore; List<String>? get warnings; String? get uploadedAt; List<ContentBlock>? get blocks;
/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentCopyWith<Content> get copyWith => _$ContentCopyWithImpl<Content>(this as Content, _$identity);

  /// Serializes this Content to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Content&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.contentMarkdown, contentMarkdown) || other.contentMarkdown == contentMarkdown)&&const DeepCollectionEquality().equals(other.altTextsGenerated, altTextsGenerated)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore)&&const DeepCollectionEquality().equals(other.warnings, warnings)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other.blocks, blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,moduleId,title,type,text,fileName,fileUrl,fileSize,linkUrl,status,contentMarkdown,const DeepCollectionEquality().hash(altTextsGenerated),accessibilityScore,const DeepCollectionEquality().hash(warnings),uploadedAt,const DeepCollectionEquality().hash(blocks));

@override
String toString() {
  return 'Content(id: $id, courseId: $courseId, moduleId: $moduleId, title: $title, type: $type, text: $text, fileName: $fileName, fileUrl: $fileUrl, fileSize: $fileSize, linkUrl: $linkUrl, status: $status, contentMarkdown: $contentMarkdown, altTextsGenerated: $altTextsGenerated, accessibilityScore: $accessibilityScore, warnings: $warnings, uploadedAt: $uploadedAt, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $ContentCopyWith<$Res>  {
  factory $ContentCopyWith(Content value, $Res Function(Content) _then) = _$ContentCopyWithImpl;
@useResult
$Res call({
 String id, String courseId, String moduleId, String title, String type, String? text, String? fileName, String? fileUrl, String? fileSize, String? linkUrl, String status, String? contentMarkdown, List<GeneratedAltText>? altTextsGenerated, int accessibilityScore, List<String>? warnings, String? uploadedAt, List<ContentBlock>? blocks
});




}
/// @nodoc
class _$ContentCopyWithImpl<$Res>
    implements $ContentCopyWith<$Res> {
  _$ContentCopyWithImpl(this._self, this._then);

  final Content _self;
  final $Res Function(Content) _then;

/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courseId = null,Object? moduleId = null,Object? title = null,Object? type = null,Object? text = freezed,Object? fileName = freezed,Object? fileUrl = freezed,Object? fileSize = freezed,Object? linkUrl = freezed,Object? status = null,Object? contentMarkdown = freezed,Object? altTextsGenerated = freezed,Object? accessibilityScore = null,Object? warnings = freezed,Object? uploadedAt = freezed,Object? blocks = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as String?,linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,contentMarkdown: freezed == contentMarkdown ? _self.contentMarkdown : contentMarkdown // ignore: cast_nullable_to_non_nullable
as String?,altTextsGenerated: freezed == altTextsGenerated ? _self.altTextsGenerated : altTextsGenerated // ignore: cast_nullable_to_non_nullable
as List<GeneratedAltText>?,accessibilityScore: null == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int,warnings: freezed == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>?,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as String?,blocks: freezed == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ContentBlock>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Content].
extension ContentPatterns on Content {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Content value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Content() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Content value)  $default,){
final _that = this;
switch (_that) {
case _Content():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Content value)?  $default,){
final _that = this;
switch (_that) {
case _Content() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String courseId,  String moduleId,  String title,  String type,  String? text,  String? fileName,  String? fileUrl,  String? fileSize,  String? linkUrl,  String status,  String? contentMarkdown,  List<GeneratedAltText>? altTextsGenerated,  int accessibilityScore,  List<String>? warnings,  String? uploadedAt,  List<ContentBlock>? blocks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Content() when $default != null:
return $default(_that.id,_that.courseId,_that.moduleId,_that.title,_that.type,_that.text,_that.fileName,_that.fileUrl,_that.fileSize,_that.linkUrl,_that.status,_that.contentMarkdown,_that.altTextsGenerated,_that.accessibilityScore,_that.warnings,_that.uploadedAt,_that.blocks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String courseId,  String moduleId,  String title,  String type,  String? text,  String? fileName,  String? fileUrl,  String? fileSize,  String? linkUrl,  String status,  String? contentMarkdown,  List<GeneratedAltText>? altTextsGenerated,  int accessibilityScore,  List<String>? warnings,  String? uploadedAt,  List<ContentBlock>? blocks)  $default,) {final _that = this;
switch (_that) {
case _Content():
return $default(_that.id,_that.courseId,_that.moduleId,_that.title,_that.type,_that.text,_that.fileName,_that.fileUrl,_that.fileSize,_that.linkUrl,_that.status,_that.contentMarkdown,_that.altTextsGenerated,_that.accessibilityScore,_that.warnings,_that.uploadedAt,_that.blocks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String courseId,  String moduleId,  String title,  String type,  String? text,  String? fileName,  String? fileUrl,  String? fileSize,  String? linkUrl,  String status,  String? contentMarkdown,  List<GeneratedAltText>? altTextsGenerated,  int accessibilityScore,  List<String>? warnings,  String? uploadedAt,  List<ContentBlock>? blocks)?  $default,) {final _that = this;
switch (_that) {
case _Content() when $default != null:
return $default(_that.id,_that.courseId,_that.moduleId,_that.title,_that.type,_that.text,_that.fileName,_that.fileUrl,_that.fileSize,_that.linkUrl,_that.status,_that.contentMarkdown,_that.altTextsGenerated,_that.accessibilityScore,_that.warnings,_that.uploadedAt,_that.blocks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Content implements Content {
  const _Content({required this.id, required this.courseId, required this.moduleId, required this.title, required this.type, this.text, this.fileName, this.fileUrl, this.fileSize, this.linkUrl, required this.status, this.contentMarkdown, final  List<GeneratedAltText>? altTextsGenerated, this.accessibilityScore = 0, final  List<String>? warnings, this.uploadedAt, final  List<ContentBlock>? blocks}): _altTextsGenerated = altTextsGenerated,_warnings = warnings,_blocks = blocks;
  factory _Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);

@override final  String id;
@override final  String courseId;
@override final  String moduleId;
@override final  String title;
@override final  String type;
@override final  String? text;
@override final  String? fileName;
@override final  String? fileUrl;
@override final  String? fileSize;
@override final  String? linkUrl;
@override final  String status;
@override final  String? contentMarkdown;
 final  List<GeneratedAltText>? _altTextsGenerated;
@override List<GeneratedAltText>? get altTextsGenerated {
  final value = _altTextsGenerated;
  if (value == null) return null;
  if (_altTextsGenerated is EqualUnmodifiableListView) return _altTextsGenerated;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  int accessibilityScore;
 final  List<String>? _warnings;
@override List<String>? get warnings {
  final value = _warnings;
  if (value == null) return null;
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? uploadedAt;
 final  List<ContentBlock>? _blocks;
@override List<ContentBlock>? get blocks {
  final value = _blocks;
  if (value == null) return null;
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentCopyWith<_Content> get copyWith => __$ContentCopyWithImpl<_Content>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Content&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.moduleId, moduleId) || other.moduleId == moduleId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.contentMarkdown, contentMarkdown) || other.contentMarkdown == contentMarkdown)&&const DeepCollectionEquality().equals(other._altTextsGenerated, _altTextsGenerated)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore)&&const DeepCollectionEquality().equals(other._warnings, _warnings)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&const DeepCollectionEquality().equals(other._blocks, _blocks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courseId,moduleId,title,type,text,fileName,fileUrl,fileSize,linkUrl,status,contentMarkdown,const DeepCollectionEquality().hash(_altTextsGenerated),accessibilityScore,const DeepCollectionEquality().hash(_warnings),uploadedAt,const DeepCollectionEquality().hash(_blocks));

@override
String toString() {
  return 'Content(id: $id, courseId: $courseId, moduleId: $moduleId, title: $title, type: $type, text: $text, fileName: $fileName, fileUrl: $fileUrl, fileSize: $fileSize, linkUrl: $linkUrl, status: $status, contentMarkdown: $contentMarkdown, altTextsGenerated: $altTextsGenerated, accessibilityScore: $accessibilityScore, warnings: $warnings, uploadedAt: $uploadedAt, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class _$ContentCopyWith<$Res> implements $ContentCopyWith<$Res> {
  factory _$ContentCopyWith(_Content value, $Res Function(_Content) _then) = __$ContentCopyWithImpl;
@override @useResult
$Res call({
 String id, String courseId, String moduleId, String title, String type, String? text, String? fileName, String? fileUrl, String? fileSize, String? linkUrl, String status, String? contentMarkdown, List<GeneratedAltText>? altTextsGenerated, int accessibilityScore, List<String>? warnings, String? uploadedAt, List<ContentBlock>? blocks
});




}
/// @nodoc
class __$ContentCopyWithImpl<$Res>
    implements _$ContentCopyWith<$Res> {
  __$ContentCopyWithImpl(this._self, this._then);

  final _Content _self;
  final $Res Function(_Content) _then;

/// Create a copy of Content
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courseId = null,Object? moduleId = null,Object? title = null,Object? type = null,Object? text = freezed,Object? fileName = freezed,Object? fileUrl = freezed,Object? fileSize = freezed,Object? linkUrl = freezed,Object? status = null,Object? contentMarkdown = freezed,Object? altTextsGenerated = freezed,Object? accessibilityScore = null,Object? warnings = freezed,Object? uploadedAt = freezed,Object? blocks = freezed,}) {
  return _then(_Content(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,moduleId: null == moduleId ? _self.moduleId : moduleId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as String?,linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,contentMarkdown: freezed == contentMarkdown ? _self.contentMarkdown : contentMarkdown // ignore: cast_nullable_to_non_nullable
as String?,altTextsGenerated: freezed == altTextsGenerated ? _self._altTextsGenerated : altTextsGenerated // ignore: cast_nullable_to_non_nullable
as List<GeneratedAltText>?,accessibilityScore: null == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int,warnings: freezed == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>?,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as String?,blocks: freezed == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ContentBlock>?,
  ));
}


}

// dart format on
