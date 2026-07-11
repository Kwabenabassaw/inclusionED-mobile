// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Module _$ModuleFromJson(Map<String, dynamic> json) => _Module(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  title: json['title'] as String,
  weekNumber: (json['weekNumber'] as num).toInt(),
  description: json['description'] as String,
  orderIndex: json['orderIndex'] as num,
  isPublished: json['isPublished'] as bool,
  status: $enumDecode(_$ModuleStatusEnumMap, json['status']),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ModuleToJson(_Module instance) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'title': instance.title,
  'weekNumber': instance.weekNumber,
  'description': instance.description,
  'orderIndex': instance.orderIndex,
  'isPublished': instance.isPublished,
  'status': _$ModuleStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$ModuleStatusEnumMap = {
  ModuleStatus.draft: 'DRAFT',
  ModuleStatus.ready: 'READY',
  ModuleStatus.published: 'PUBLISHED',
  ModuleStatus.archived: 'ARCHIVED',
};
