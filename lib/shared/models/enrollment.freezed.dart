// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enrollment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnrollmentProgress {

 List<String> get completedModuleIds; List<String> get completedContentIds; List<String> get completedQuizIds;
/// Create a copy of EnrollmentProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrollmentProgressCopyWith<EnrollmentProgress> get copyWith => _$EnrollmentProgressCopyWithImpl<EnrollmentProgress>(this as EnrollmentProgress, _$identity);

  /// Serializes this EnrollmentProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrollmentProgress&&const DeepCollectionEquality().equals(other.completedModuleIds, completedModuleIds)&&const DeepCollectionEquality().equals(other.completedContentIds, completedContentIds)&&const DeepCollectionEquality().equals(other.completedQuizIds, completedQuizIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(completedModuleIds),const DeepCollectionEquality().hash(completedContentIds),const DeepCollectionEquality().hash(completedQuizIds));

@override
String toString() {
  return 'EnrollmentProgress(completedModuleIds: $completedModuleIds, completedContentIds: $completedContentIds, completedQuizIds: $completedQuizIds)';
}


}

/// @nodoc
abstract mixin class $EnrollmentProgressCopyWith<$Res>  {
  factory $EnrollmentProgressCopyWith(EnrollmentProgress value, $Res Function(EnrollmentProgress) _then) = _$EnrollmentProgressCopyWithImpl;
@useResult
$Res call({
 List<String> completedModuleIds, List<String> completedContentIds, List<String> completedQuizIds
});




}
/// @nodoc
class _$EnrollmentProgressCopyWithImpl<$Res>
    implements $EnrollmentProgressCopyWith<$Res> {
  _$EnrollmentProgressCopyWithImpl(this._self, this._then);

  final EnrollmentProgress _self;
  final $Res Function(EnrollmentProgress) _then;

/// Create a copy of EnrollmentProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completedModuleIds = null,Object? completedContentIds = null,Object? completedQuizIds = null,}) {
  return _then(_self.copyWith(
completedModuleIds: null == completedModuleIds ? _self.completedModuleIds : completedModuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,completedContentIds: null == completedContentIds ? _self.completedContentIds : completedContentIds // ignore: cast_nullable_to_non_nullable
as List<String>,completedQuizIds: null == completedQuizIds ? _self.completedQuizIds : completedQuizIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [EnrollmentProgress].
extension EnrollmentProgressPatterns on EnrollmentProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrollmentProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrollmentProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrollmentProgress value)  $default,){
final _that = this;
switch (_that) {
case _EnrollmentProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrollmentProgress value)?  $default,){
final _that = this;
switch (_that) {
case _EnrollmentProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> completedModuleIds,  List<String> completedContentIds,  List<String> completedQuizIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrollmentProgress() when $default != null:
return $default(_that.completedModuleIds,_that.completedContentIds,_that.completedQuizIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> completedModuleIds,  List<String> completedContentIds,  List<String> completedQuizIds)  $default,) {final _that = this;
switch (_that) {
case _EnrollmentProgress():
return $default(_that.completedModuleIds,_that.completedContentIds,_that.completedQuizIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> completedModuleIds,  List<String> completedContentIds,  List<String> completedQuizIds)?  $default,) {final _that = this;
switch (_that) {
case _EnrollmentProgress() when $default != null:
return $default(_that.completedModuleIds,_that.completedContentIds,_that.completedQuizIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrollmentProgress implements EnrollmentProgress {
  const _EnrollmentProgress({final  List<String> completedModuleIds = const [], final  List<String> completedContentIds = const [], final  List<String> completedQuizIds = const []}): _completedModuleIds = completedModuleIds,_completedContentIds = completedContentIds,_completedQuizIds = completedQuizIds;
  factory _EnrollmentProgress.fromJson(Map<String, dynamic> json) => _$EnrollmentProgressFromJson(json);

 final  List<String> _completedModuleIds;
@override@JsonKey() List<String> get completedModuleIds {
  if (_completedModuleIds is EqualUnmodifiableListView) return _completedModuleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedModuleIds);
}

 final  List<String> _completedContentIds;
@override@JsonKey() List<String> get completedContentIds {
  if (_completedContentIds is EqualUnmodifiableListView) return _completedContentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedContentIds);
}

 final  List<String> _completedQuizIds;
@override@JsonKey() List<String> get completedQuizIds {
  if (_completedQuizIds is EqualUnmodifiableListView) return _completedQuizIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedQuizIds);
}


/// Create a copy of EnrollmentProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrollmentProgressCopyWith<_EnrollmentProgress> get copyWith => __$EnrollmentProgressCopyWithImpl<_EnrollmentProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrollmentProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrollmentProgress&&const DeepCollectionEquality().equals(other._completedModuleIds, _completedModuleIds)&&const DeepCollectionEquality().equals(other._completedContentIds, _completedContentIds)&&const DeepCollectionEquality().equals(other._completedQuizIds, _completedQuizIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_completedModuleIds),const DeepCollectionEquality().hash(_completedContentIds),const DeepCollectionEquality().hash(_completedQuizIds));

@override
String toString() {
  return 'EnrollmentProgress(completedModuleIds: $completedModuleIds, completedContentIds: $completedContentIds, completedQuizIds: $completedQuizIds)';
}


}

/// @nodoc
abstract mixin class _$EnrollmentProgressCopyWith<$Res> implements $EnrollmentProgressCopyWith<$Res> {
  factory _$EnrollmentProgressCopyWith(_EnrollmentProgress value, $Res Function(_EnrollmentProgress) _then) = __$EnrollmentProgressCopyWithImpl;
@override @useResult
$Res call({
 List<String> completedModuleIds, List<String> completedContentIds, List<String> completedQuizIds
});




}
/// @nodoc
class __$EnrollmentProgressCopyWithImpl<$Res>
    implements _$EnrollmentProgressCopyWith<$Res> {
  __$EnrollmentProgressCopyWithImpl(this._self, this._then);

  final _EnrollmentProgress _self;
  final $Res Function(_EnrollmentProgress) _then;

/// Create a copy of EnrollmentProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completedModuleIds = null,Object? completedContentIds = null,Object? completedQuizIds = null,}) {
  return _then(_EnrollmentProgress(
completedModuleIds: null == completedModuleIds ? _self._completedModuleIds : completedModuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,completedContentIds: null == completedContentIds ? _self._completedContentIds : completedContentIds // ignore: cast_nullable_to_non_nullable
as List<String>,completedQuizIds: null == completedQuizIds ? _self._completedQuizIds : completedQuizIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$EnrollmentProgressSummary {

 double get percentage; String? get lastAccessedAt;
/// Create a copy of EnrollmentProgressSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrollmentProgressSummaryCopyWith<EnrollmentProgressSummary> get copyWith => _$EnrollmentProgressSummaryCopyWithImpl<EnrollmentProgressSummary>(this as EnrollmentProgressSummary, _$identity);

  /// Serializes this EnrollmentProgressSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrollmentProgressSummary&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.lastAccessedAt, lastAccessedAt) || other.lastAccessedAt == lastAccessedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,percentage,lastAccessedAt);

@override
String toString() {
  return 'EnrollmentProgressSummary(percentage: $percentage, lastAccessedAt: $lastAccessedAt)';
}


}

/// @nodoc
abstract mixin class $EnrollmentProgressSummaryCopyWith<$Res>  {
  factory $EnrollmentProgressSummaryCopyWith(EnrollmentProgressSummary value, $Res Function(EnrollmentProgressSummary) _then) = _$EnrollmentProgressSummaryCopyWithImpl;
@useResult
$Res call({
 double percentage, String? lastAccessedAt
});




}
/// @nodoc
class _$EnrollmentProgressSummaryCopyWithImpl<$Res>
    implements $EnrollmentProgressSummaryCopyWith<$Res> {
  _$EnrollmentProgressSummaryCopyWithImpl(this._self, this._then);

  final EnrollmentProgressSummary _self;
  final $Res Function(EnrollmentProgressSummary) _then;

/// Create a copy of EnrollmentProgressSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? percentage = null,Object? lastAccessedAt = freezed,}) {
  return _then(_self.copyWith(
percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,lastAccessedAt: freezed == lastAccessedAt ? _self.lastAccessedAt : lastAccessedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EnrollmentProgressSummary].
extension EnrollmentProgressSummaryPatterns on EnrollmentProgressSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrollmentProgressSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrollmentProgressSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrollmentProgressSummary value)  $default,){
final _that = this;
switch (_that) {
case _EnrollmentProgressSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrollmentProgressSummary value)?  $default,){
final _that = this;
switch (_that) {
case _EnrollmentProgressSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double percentage,  String? lastAccessedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrollmentProgressSummary() when $default != null:
return $default(_that.percentage,_that.lastAccessedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double percentage,  String? lastAccessedAt)  $default,) {final _that = this;
switch (_that) {
case _EnrollmentProgressSummary():
return $default(_that.percentage,_that.lastAccessedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double percentage,  String? lastAccessedAt)?  $default,) {final _that = this;
switch (_that) {
case _EnrollmentProgressSummary() when $default != null:
return $default(_that.percentage,_that.lastAccessedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrollmentProgressSummary implements EnrollmentProgressSummary {
  const _EnrollmentProgressSummary({this.percentage = 0.0, this.lastAccessedAt});
  factory _EnrollmentProgressSummary.fromJson(Map<String, dynamic> json) => _$EnrollmentProgressSummaryFromJson(json);

@override@JsonKey() final  double percentage;
@override final  String? lastAccessedAt;

/// Create a copy of EnrollmentProgressSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrollmentProgressSummaryCopyWith<_EnrollmentProgressSummary> get copyWith => __$EnrollmentProgressSummaryCopyWithImpl<_EnrollmentProgressSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrollmentProgressSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrollmentProgressSummary&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.lastAccessedAt, lastAccessedAt) || other.lastAccessedAt == lastAccessedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,percentage,lastAccessedAt);

@override
String toString() {
  return 'EnrollmentProgressSummary(percentage: $percentage, lastAccessedAt: $lastAccessedAt)';
}


}

/// @nodoc
abstract mixin class _$EnrollmentProgressSummaryCopyWith<$Res> implements $EnrollmentProgressSummaryCopyWith<$Res> {
  factory _$EnrollmentProgressSummaryCopyWith(_EnrollmentProgressSummary value, $Res Function(_EnrollmentProgressSummary) _then) = __$EnrollmentProgressSummaryCopyWithImpl;
@override @useResult
$Res call({
 double percentage, String? lastAccessedAt
});




}
/// @nodoc
class __$EnrollmentProgressSummaryCopyWithImpl<$Res>
    implements _$EnrollmentProgressSummaryCopyWith<$Res> {
  __$EnrollmentProgressSummaryCopyWithImpl(this._self, this._then);

  final _EnrollmentProgressSummary _self;
  final $Res Function(_EnrollmentProgressSummary) _then;

/// Create a copy of EnrollmentProgressSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? percentage = null,Object? lastAccessedAt = freezed,}) {
  return _then(_EnrollmentProgressSummary(
percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,lastAccessedAt: freezed == lastAccessedAt ? _self.lastAccessedAt : lastAccessedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EnrollmentProgressOverall {

 EnrollmentProgressSummary? get overall;
/// Create a copy of EnrollmentProgressOverall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrollmentProgressOverallCopyWith<EnrollmentProgressOverall> get copyWith => _$EnrollmentProgressOverallCopyWithImpl<EnrollmentProgressOverall>(this as EnrollmentProgressOverall, _$identity);

  /// Serializes this EnrollmentProgressOverall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrollmentProgressOverall&&(identical(other.overall, overall) || other.overall == overall));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overall);

@override
String toString() {
  return 'EnrollmentProgressOverall(overall: $overall)';
}


}

/// @nodoc
abstract mixin class $EnrollmentProgressOverallCopyWith<$Res>  {
  factory $EnrollmentProgressOverallCopyWith(EnrollmentProgressOverall value, $Res Function(EnrollmentProgressOverall) _then) = _$EnrollmentProgressOverallCopyWithImpl;
@useResult
$Res call({
 EnrollmentProgressSummary? overall
});


$EnrollmentProgressSummaryCopyWith<$Res>? get overall;

}
/// @nodoc
class _$EnrollmentProgressOverallCopyWithImpl<$Res>
    implements $EnrollmentProgressOverallCopyWith<$Res> {
  _$EnrollmentProgressOverallCopyWithImpl(this._self, this._then);

  final EnrollmentProgressOverall _self;
  final $Res Function(EnrollmentProgressOverall) _then;

/// Create a copy of EnrollmentProgressOverall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overall = freezed,}) {
  return _then(_self.copyWith(
overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as EnrollmentProgressSummary?,
  ));
}
/// Create a copy of EnrollmentProgressOverall
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentProgressSummaryCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $EnrollmentProgressSummaryCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnrollmentProgressOverall].
extension EnrollmentProgressOverallPatterns on EnrollmentProgressOverall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrollmentProgressOverall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrollmentProgressOverall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrollmentProgressOverall value)  $default,){
final _that = this;
switch (_that) {
case _EnrollmentProgressOverall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrollmentProgressOverall value)?  $default,){
final _that = this;
switch (_that) {
case _EnrollmentProgressOverall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EnrollmentProgressSummary? overall)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrollmentProgressOverall() when $default != null:
return $default(_that.overall);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EnrollmentProgressSummary? overall)  $default,) {final _that = this;
switch (_that) {
case _EnrollmentProgressOverall():
return $default(_that.overall);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EnrollmentProgressSummary? overall)?  $default,) {final _that = this;
switch (_that) {
case _EnrollmentProgressOverall() when $default != null:
return $default(_that.overall);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrollmentProgressOverall implements EnrollmentProgressOverall {
  const _EnrollmentProgressOverall({this.overall});
  factory _EnrollmentProgressOverall.fromJson(Map<String, dynamic> json) => _$EnrollmentProgressOverallFromJson(json);

@override final  EnrollmentProgressSummary? overall;

/// Create a copy of EnrollmentProgressOverall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrollmentProgressOverallCopyWith<_EnrollmentProgressOverall> get copyWith => __$EnrollmentProgressOverallCopyWithImpl<_EnrollmentProgressOverall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrollmentProgressOverallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrollmentProgressOverall&&(identical(other.overall, overall) || other.overall == overall));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,overall);

@override
String toString() {
  return 'EnrollmentProgressOverall(overall: $overall)';
}


}

/// @nodoc
abstract mixin class _$EnrollmentProgressOverallCopyWith<$Res> implements $EnrollmentProgressOverallCopyWith<$Res> {
  factory _$EnrollmentProgressOverallCopyWith(_EnrollmentProgressOverall value, $Res Function(_EnrollmentProgressOverall) _then) = __$EnrollmentProgressOverallCopyWithImpl;
@override @useResult
$Res call({
 EnrollmentProgressSummary? overall
});


@override $EnrollmentProgressSummaryCopyWith<$Res>? get overall;

}
/// @nodoc
class __$EnrollmentProgressOverallCopyWithImpl<$Res>
    implements _$EnrollmentProgressOverallCopyWith<$Res> {
  __$EnrollmentProgressOverallCopyWithImpl(this._self, this._then);

  final _EnrollmentProgressOverall _self;
  final $Res Function(_EnrollmentProgressOverall) _then;

/// Create a copy of EnrollmentProgressOverall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overall = freezed,}) {
  return _then(_EnrollmentProgressOverall(
overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as EnrollmentProgressSummary?,
  ));
}

/// Create a copy of EnrollmentProgressOverall
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentProgressSummaryCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $EnrollmentProgressSummaryCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// @nodoc
mixin _$Enrollment {

 String get id; String get studentId; String get courseId; EnrollmentStatus get status; EnrollmentProgress? get progress; EnrollmentProgressOverall? get progressSummary; String get enrolledAt; String? get updatedAt;
/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrollmentCopyWith<Enrollment> get copyWith => _$EnrollmentCopyWithImpl<Enrollment>(this as Enrollment, _$identity);

  /// Serializes this Enrollment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Enrollment&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.progressSummary, progressSummary) || other.progressSummary == progressSummary)&&(identical(other.enrolledAt, enrolledAt) || other.enrolledAt == enrolledAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,courseId,status,progress,progressSummary,enrolledAt,updatedAt);

@override
String toString() {
  return 'Enrollment(id: $id, studentId: $studentId, courseId: $courseId, status: $status, progress: $progress, progressSummary: $progressSummary, enrolledAt: $enrolledAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EnrollmentCopyWith<$Res>  {
  factory $EnrollmentCopyWith(Enrollment value, $Res Function(Enrollment) _then) = _$EnrollmentCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String courseId, EnrollmentStatus status, EnrollmentProgress? progress, EnrollmentProgressOverall? progressSummary, String enrolledAt, String? updatedAt
});


$EnrollmentProgressCopyWith<$Res>? get progress;$EnrollmentProgressOverallCopyWith<$Res>? get progressSummary;

}
/// @nodoc
class _$EnrollmentCopyWithImpl<$Res>
    implements $EnrollmentCopyWith<$Res> {
  _$EnrollmentCopyWithImpl(this._self, this._then);

  final Enrollment _self;
  final $Res Function(Enrollment) _then;

/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? courseId = null,Object? status = null,Object? progress = freezed,Object? progressSummary = freezed,Object? enrolledAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnrollmentStatus,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EnrollmentProgress?,progressSummary: freezed == progressSummary ? _self.progressSummary : progressSummary // ignore: cast_nullable_to_non_nullable
as EnrollmentProgressOverall?,enrolledAt: null == enrolledAt ? _self.enrolledAt : enrolledAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $EnrollmentProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentProgressOverallCopyWith<$Res>? get progressSummary {
    if (_self.progressSummary == null) {
    return null;
  }

  return $EnrollmentProgressOverallCopyWith<$Res>(_self.progressSummary!, (value) {
    return _then(_self.copyWith(progressSummary: value));
  });
}
}


/// Adds pattern-matching-related methods to [Enrollment].
extension EnrollmentPatterns on Enrollment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Enrollment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Enrollment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Enrollment value)  $default,){
final _that = this;
switch (_that) {
case _Enrollment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Enrollment value)?  $default,){
final _that = this;
switch (_that) {
case _Enrollment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String courseId,  EnrollmentStatus status,  EnrollmentProgress? progress,  EnrollmentProgressOverall? progressSummary,  String enrolledAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Enrollment() when $default != null:
return $default(_that.id,_that.studentId,_that.courseId,_that.status,_that.progress,_that.progressSummary,_that.enrolledAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String courseId,  EnrollmentStatus status,  EnrollmentProgress? progress,  EnrollmentProgressOverall? progressSummary,  String enrolledAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Enrollment():
return $default(_that.id,_that.studentId,_that.courseId,_that.status,_that.progress,_that.progressSummary,_that.enrolledAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String courseId,  EnrollmentStatus status,  EnrollmentProgress? progress,  EnrollmentProgressOverall? progressSummary,  String enrolledAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Enrollment() when $default != null:
return $default(_that.id,_that.studentId,_that.courseId,_that.status,_that.progress,_that.progressSummary,_that.enrolledAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Enrollment implements Enrollment {
  const _Enrollment({required this.id, required this.studentId, required this.courseId, this.status = EnrollmentStatus.pending, this.progress, this.progressSummary, required this.enrolledAt, this.updatedAt});
  factory _Enrollment.fromJson(Map<String, dynamic> json) => _$EnrollmentFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String courseId;
@override@JsonKey() final  EnrollmentStatus status;
@override final  EnrollmentProgress? progress;
@override final  EnrollmentProgressOverall? progressSummary;
@override final  String enrolledAt;
@override final  String? updatedAt;

/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrollmentCopyWith<_Enrollment> get copyWith => __$EnrollmentCopyWithImpl<_Enrollment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrollmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Enrollment&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.progressSummary, progressSummary) || other.progressSummary == progressSummary)&&(identical(other.enrolledAt, enrolledAt) || other.enrolledAt == enrolledAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,courseId,status,progress,progressSummary,enrolledAt,updatedAt);

@override
String toString() {
  return 'Enrollment(id: $id, studentId: $studentId, courseId: $courseId, status: $status, progress: $progress, progressSummary: $progressSummary, enrolledAt: $enrolledAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EnrollmentCopyWith<$Res> implements $EnrollmentCopyWith<$Res> {
  factory _$EnrollmentCopyWith(_Enrollment value, $Res Function(_Enrollment) _then) = __$EnrollmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String courseId, EnrollmentStatus status, EnrollmentProgress? progress, EnrollmentProgressOverall? progressSummary, String enrolledAt, String? updatedAt
});


@override $EnrollmentProgressCopyWith<$Res>? get progress;@override $EnrollmentProgressOverallCopyWith<$Res>? get progressSummary;

}
/// @nodoc
class __$EnrollmentCopyWithImpl<$Res>
    implements _$EnrollmentCopyWith<$Res> {
  __$EnrollmentCopyWithImpl(this._self, this._then);

  final _Enrollment _self;
  final $Res Function(_Enrollment) _then;

/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? courseId = null,Object? status = null,Object? progress = freezed,Object? progressSummary = freezed,Object? enrolledAt = null,Object? updatedAt = freezed,}) {
  return _then(_Enrollment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EnrollmentStatus,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EnrollmentProgress?,progressSummary: freezed == progressSummary ? _self.progressSummary : progressSummary // ignore: cast_nullable_to_non_nullable
as EnrollmentProgressOverall?,enrolledAt: null == enrolledAt ? _self.enrolledAt : enrolledAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $EnrollmentProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}/// Create a copy of Enrollment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrollmentProgressOverallCopyWith<$Res>? get progressSummary {
    if (_self.progressSummary == null) {
    return null;
  }

  return $EnrollmentProgressOverallCopyWith<$Res>(_self.progressSummary!, (value) {
    return _then(_self.copyWith(progressSummary: value));
  });
}
}

// dart format on
