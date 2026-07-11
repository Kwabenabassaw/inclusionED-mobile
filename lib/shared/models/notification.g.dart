// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      referenceId: json['referenceId'] as String,
      read: json['read'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'referenceId': instance.referenceId,
      'read': instance.read,
      'createdAt': instance.createdAt,
    };
