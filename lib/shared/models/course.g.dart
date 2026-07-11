// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Course _$CourseFromJson(Map<String, dynamic> json) => _Course(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  department: json['department'] as String,
  level: json['level'] as String,
  term: json['term'] as String,
  published: json['published'] as bool,
  archived: json['archived'] as bool,
  studentsCount: (json['studentsCount'] as num?)?.toInt() ?? 0,
  accessibilityScore: (json['accessibilityScore'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String,
  instructorId: json['instructorId'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$CourseToJson(_Course instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'department': instance.department,
  'level': instance.level,
  'term': instance.term,
  'published': instance.published,
  'archived': instance.archived,
  'studentsCount': instance.studentsCount,
  'accessibilityScore': instance.accessibilityScore,
  'createdAt': instance.createdAt,
  'instructorId': instance.instructorId,
  'imageUrl': instance.imageUrl,
};
