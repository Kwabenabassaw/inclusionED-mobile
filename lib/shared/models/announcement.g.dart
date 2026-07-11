// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      createdAt: json['createdAt'] as String,
      instructorName: json['instructorName'] as String,
    );

Map<String, dynamic> _$AnnouncementToJson(_Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'createdAt': instance.createdAt,
      'instructorName': instance.instructorName,
    };
