// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Assignment _$AssignmentFromJson(Map<String, dynamic> json) => _Assignment(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  dueDate: json['dueDate'] as String,
  totalPoints: (json['totalPoints'] as num).toInt(),
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  isPublished: json['isPublished'] as bool? ?? false,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$AssignmentToJson(_Assignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'description': instance.description,
      'dueDate': instance.dueDate,
      'totalPoints': instance.totalPoints,
      'attachments': instance.attachments,
      'isPublished': instance.isPublished,
      'createdAt': instance.createdAt,
    };

_AssignmentSubmission _$AssignmentSubmissionFromJson(
  Map<String, dynamic> json,
) => _AssignmentSubmission(
  id: json['id'] as String,
  assignmentId: json['assignmentId'] as String,
  studentId: json['studentId'] as String,
  status: json['status'] as String,
  submittedFileUrl: json['submittedFileUrl'] as String,
  submittedFileName: json['submittedFileName'] as String,
  submittedAt: json['submittedAt'] as String,
  grade: (json['grade'] as num?)?.toInt(),
  feedback: json['feedback'] as String?,
  gradedBy: json['gradedBy'] as String?,
  gradedAt: json['gradedAt'] as String?,
);

Map<String, dynamic> _$AssignmentSubmissionToJson(
  _AssignmentSubmission instance,
) => <String, dynamic>{
  'id': instance.id,
  'assignmentId': instance.assignmentId,
  'studentId': instance.studentId,
  'status': instance.status,
  'submittedFileUrl': instance.submittedFileUrl,
  'submittedFileName': instance.submittedFileName,
  'submittedAt': instance.submittedAt,
  'grade': instance.grade,
  'feedback': instance.feedback,
  'gradedBy': instance.gradedBy,
  'gradedAt': instance.gradedAt,
};
