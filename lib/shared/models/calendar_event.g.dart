// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarEvent _$CalendarEventFromJson(Map<String, dynamic> json) =>
    _CalendarEvent(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      moduleId: json['moduleId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      allDay: json['allDay'] as bool,
      isPublished: json['isPublished'] as bool,
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$CalendarEventToJson(_CalendarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'allDay': instance.allDay,
      'isPublished': instance.isPublished,
      'createdBy': instance.createdBy,
    };
