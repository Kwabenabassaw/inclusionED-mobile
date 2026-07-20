// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_gamification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserGamification {

 String get userId; int get totalXp; int get level; int get currentStreak; int get longestStreak; String? get lastActivityDate; List<String> get earnedBadgeIds; int get totalNotesAdded; int get totalHighlightsAdded; int get totalLessonsCompleted;
/// Create a copy of UserGamification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserGamificationCopyWith<UserGamification> get copyWith => _$UserGamificationCopyWithImpl<UserGamification>(this as UserGamification, _$identity);

  /// Serializes this UserGamification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserGamification&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastActivityDate, lastActivityDate) || other.lastActivityDate == lastActivityDate)&&const DeepCollectionEquality().equals(other.earnedBadgeIds, earnedBadgeIds)&&(identical(other.totalNotesAdded, totalNotesAdded) || other.totalNotesAdded == totalNotesAdded)&&(identical(other.totalHighlightsAdded, totalHighlightsAdded) || other.totalHighlightsAdded == totalHighlightsAdded)&&(identical(other.totalLessonsCompleted, totalLessonsCompleted) || other.totalLessonsCompleted == totalLessonsCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,totalXp,level,currentStreak,longestStreak,lastActivityDate,const DeepCollectionEquality().hash(earnedBadgeIds),totalNotesAdded,totalHighlightsAdded,totalLessonsCompleted);

@override
String toString() {
  return 'UserGamification(userId: $userId, totalXp: $totalXp, level: $level, currentStreak: $currentStreak, longestStreak: $longestStreak, lastActivityDate: $lastActivityDate, earnedBadgeIds: $earnedBadgeIds, totalNotesAdded: $totalNotesAdded, totalHighlightsAdded: $totalHighlightsAdded, totalLessonsCompleted: $totalLessonsCompleted)';
}


}

/// @nodoc
abstract mixin class $UserGamificationCopyWith<$Res>  {
  factory $UserGamificationCopyWith(UserGamification value, $Res Function(UserGamification) _then) = _$UserGamificationCopyWithImpl;
@useResult
$Res call({
 String userId, int totalXp, int level, int currentStreak, int longestStreak, String? lastActivityDate, List<String> earnedBadgeIds, int totalNotesAdded, int totalHighlightsAdded, int totalLessonsCompleted
});




}
/// @nodoc
class _$UserGamificationCopyWithImpl<$Res>
    implements $UserGamificationCopyWith<$Res> {
  _$UserGamificationCopyWithImpl(this._self, this._then);

  final UserGamification _self;
  final $Res Function(UserGamification) _then;

/// Create a copy of UserGamification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? totalXp = null,Object? level = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastActivityDate = freezed,Object? earnedBadgeIds = null,Object? totalNotesAdded = null,Object? totalHighlightsAdded = null,Object? totalLessonsCompleted = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastActivityDate: freezed == lastActivityDate ? _self.lastActivityDate : lastActivityDate // ignore: cast_nullable_to_non_nullable
as String?,earnedBadgeIds: null == earnedBadgeIds ? _self.earnedBadgeIds : earnedBadgeIds // ignore: cast_nullable_to_non_nullable
as List<String>,totalNotesAdded: null == totalNotesAdded ? _self.totalNotesAdded : totalNotesAdded // ignore: cast_nullable_to_non_nullable
as int,totalHighlightsAdded: null == totalHighlightsAdded ? _self.totalHighlightsAdded : totalHighlightsAdded // ignore: cast_nullable_to_non_nullable
as int,totalLessonsCompleted: null == totalLessonsCompleted ? _self.totalLessonsCompleted : totalLessonsCompleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserGamification].
extension UserGamificationPatterns on UserGamification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserGamification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserGamification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserGamification value)  $default,){
final _that = this;
switch (_that) {
case _UserGamification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserGamification value)?  $default,){
final _that = this;
switch (_that) {
case _UserGamification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int totalXp,  int level,  int currentStreak,  int longestStreak,  String? lastActivityDate,  List<String> earnedBadgeIds,  int totalNotesAdded,  int totalHighlightsAdded,  int totalLessonsCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserGamification() when $default != null:
return $default(_that.userId,_that.totalXp,_that.level,_that.currentStreak,_that.longestStreak,_that.lastActivityDate,_that.earnedBadgeIds,_that.totalNotesAdded,_that.totalHighlightsAdded,_that.totalLessonsCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int totalXp,  int level,  int currentStreak,  int longestStreak,  String? lastActivityDate,  List<String> earnedBadgeIds,  int totalNotesAdded,  int totalHighlightsAdded,  int totalLessonsCompleted)  $default,) {final _that = this;
switch (_that) {
case _UserGamification():
return $default(_that.userId,_that.totalXp,_that.level,_that.currentStreak,_that.longestStreak,_that.lastActivityDate,_that.earnedBadgeIds,_that.totalNotesAdded,_that.totalHighlightsAdded,_that.totalLessonsCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int totalXp,  int level,  int currentStreak,  int longestStreak,  String? lastActivityDate,  List<String> earnedBadgeIds,  int totalNotesAdded,  int totalHighlightsAdded,  int totalLessonsCompleted)?  $default,) {final _that = this;
switch (_that) {
case _UserGamification() when $default != null:
return $default(_that.userId,_that.totalXp,_that.level,_that.currentStreak,_that.longestStreak,_that.lastActivityDate,_that.earnedBadgeIds,_that.totalNotesAdded,_that.totalHighlightsAdded,_that.totalLessonsCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserGamification implements UserGamification {
  const _UserGamification({required this.userId, this.totalXp = 0, this.level = 1, this.currentStreak = 0, this.longestStreak = 0, this.lastActivityDate, final  List<String> earnedBadgeIds = const [], this.totalNotesAdded = 0, this.totalHighlightsAdded = 0, this.totalLessonsCompleted = 0}): _earnedBadgeIds = earnedBadgeIds;
  factory _UserGamification.fromJson(Map<String, dynamic> json) => _$UserGamificationFromJson(json);

@override final  String userId;
@override@JsonKey() final  int totalXp;
@override@JsonKey() final  int level;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
@override final  String? lastActivityDate;
 final  List<String> _earnedBadgeIds;
@override@JsonKey() List<String> get earnedBadgeIds {
  if (_earnedBadgeIds is EqualUnmodifiableListView) return _earnedBadgeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_earnedBadgeIds);
}

@override@JsonKey() final  int totalNotesAdded;
@override@JsonKey() final  int totalHighlightsAdded;
@override@JsonKey() final  int totalLessonsCompleted;

/// Create a copy of UserGamification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserGamificationCopyWith<_UserGamification> get copyWith => __$UserGamificationCopyWithImpl<_UserGamification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserGamificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserGamification&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalXp, totalXp) || other.totalXp == totalXp)&&(identical(other.level, level) || other.level == level)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastActivityDate, lastActivityDate) || other.lastActivityDate == lastActivityDate)&&const DeepCollectionEquality().equals(other._earnedBadgeIds, _earnedBadgeIds)&&(identical(other.totalNotesAdded, totalNotesAdded) || other.totalNotesAdded == totalNotesAdded)&&(identical(other.totalHighlightsAdded, totalHighlightsAdded) || other.totalHighlightsAdded == totalHighlightsAdded)&&(identical(other.totalLessonsCompleted, totalLessonsCompleted) || other.totalLessonsCompleted == totalLessonsCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,totalXp,level,currentStreak,longestStreak,lastActivityDate,const DeepCollectionEquality().hash(_earnedBadgeIds),totalNotesAdded,totalHighlightsAdded,totalLessonsCompleted);

@override
String toString() {
  return 'UserGamification(userId: $userId, totalXp: $totalXp, level: $level, currentStreak: $currentStreak, longestStreak: $longestStreak, lastActivityDate: $lastActivityDate, earnedBadgeIds: $earnedBadgeIds, totalNotesAdded: $totalNotesAdded, totalHighlightsAdded: $totalHighlightsAdded, totalLessonsCompleted: $totalLessonsCompleted)';
}


}

/// @nodoc
abstract mixin class _$UserGamificationCopyWith<$Res> implements $UserGamificationCopyWith<$Res> {
  factory _$UserGamificationCopyWith(_UserGamification value, $Res Function(_UserGamification) _then) = __$UserGamificationCopyWithImpl;
@override @useResult
$Res call({
 String userId, int totalXp, int level, int currentStreak, int longestStreak, String? lastActivityDate, List<String> earnedBadgeIds, int totalNotesAdded, int totalHighlightsAdded, int totalLessonsCompleted
});




}
/// @nodoc
class __$UserGamificationCopyWithImpl<$Res>
    implements _$UserGamificationCopyWith<$Res> {
  __$UserGamificationCopyWithImpl(this._self, this._then);

  final _UserGamification _self;
  final $Res Function(_UserGamification) _then;

/// Create a copy of UserGamification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? totalXp = null,Object? level = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastActivityDate = freezed,Object? earnedBadgeIds = null,Object? totalNotesAdded = null,Object? totalHighlightsAdded = null,Object? totalLessonsCompleted = null,}) {
  return _then(_UserGamification(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalXp: null == totalXp ? _self.totalXp : totalXp // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastActivityDate: freezed == lastActivityDate ? _self.lastActivityDate : lastActivityDate // ignore: cast_nullable_to_non_nullable
as String?,earnedBadgeIds: null == earnedBadgeIds ? _self._earnedBadgeIds : earnedBadgeIds // ignore: cast_nullable_to_non_nullable
as List<String>,totalNotesAdded: null == totalNotesAdded ? _self.totalNotesAdded : totalNotesAdded // ignore: cast_nullable_to_non_nullable
as int,totalHighlightsAdded: null == totalHighlightsAdded ? _self.totalHighlightsAdded : totalHighlightsAdded // ignore: cast_nullable_to_non_nullable
as int,totalLessonsCompleted: null == totalLessonsCompleted ? _self.totalLessonsCompleted : totalLessonsCompleted // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
