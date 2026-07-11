// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  uid: json['uid'] as String,
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  email: json['email'] as String,
  role:
      $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.student,
  department: json['department'] as String? ?? 'General',
  faculty: json['faculty'] as String?,
  academicLevel: json['academicLevel'] as String?,
  studentId: json['studentId'] as String?,
  avatar: json['avatar'] as String,
  bio: json['bio'] as String?,
  joinedAt: json['joinedAt'] as String,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'role': _$UserRoleEnumMap[instance.role]!,
      'department': instance.department,
      'faculty': instance.faculty,
      'academicLevel': instance.academicLevel,
      'studentId': instance.studentId,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'joinedAt': instance.joinedAt,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'ADMIN',
  UserRole.instructor: 'INSTRUCTOR',
  UserRole.student: 'STUDENT',
};
