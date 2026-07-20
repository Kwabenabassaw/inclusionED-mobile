import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';
part 'assignment.g.dart';

@freezed
abstract class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    required String courseId,
    required String title,
    required String description,
    required String dueDate,
    required int totalPoints,
    @Default([]) List<Map<String, dynamic>> attachments,
    @Default(false) bool isPublished,
    required String createdAt,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) => _$AssignmentFromJson(json);
}

@freezed
abstract class AssignmentSubmission with _$AssignmentSubmission {
  const factory AssignmentSubmission({
    required String id,
    required String assignmentId,
    required String studentId,
    required String status, // "SUBMITTED", "GRADED", "LATE"
    required String submittedFileUrl,
    required String submittedFileName,
    required String submittedAt,
    int? grade,
    String? feedback,
    String? gradedBy,
    String? gradedAt,
  }) = _AssignmentSubmission;

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) => _$AssignmentSubmissionFromJson(json);
}
