import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrollment.freezed.dart';
part 'enrollment.g.dart';

enum EnrollmentStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('ACTIVE') active,
  @JsonValue('REJECTED') rejected,
  @JsonValue('COMPLETED') completed,
}

@freezed
abstract class EnrollmentProgress with _$EnrollmentProgress {
  const factory EnrollmentProgress({
    @Default([]) List<String> completedModuleIds,
    @Default([]) List<String> completedContentIds,
    @Default([]) List<String> completedQuizIds,
  }) = _EnrollmentProgress;

  factory EnrollmentProgress.fromJson(Map<String, dynamic> json) => _$EnrollmentProgressFromJson(json);
}
@freezed
abstract class EnrollmentProgressSummary with _$EnrollmentProgressSummary {
  const factory EnrollmentProgressSummary({
    @Default(0.0) double percentage,
    String? lastAccessedAt,
  }) = _EnrollmentProgressSummary;

  factory EnrollmentProgressSummary.fromJson(Map<String, dynamic> json) => _$EnrollmentProgressSummaryFromJson(json);
}

@freezed
abstract class EnrollmentProgressOverall with _$EnrollmentProgressOverall {
  const factory EnrollmentProgressOverall({
    EnrollmentProgressSummary? overall,
  }) = _EnrollmentProgressOverall;

  factory EnrollmentProgressOverall.fromJson(Map<String, dynamic> json) => _$EnrollmentProgressOverallFromJson(json);
}

@freezed
abstract class Enrollment with _$Enrollment {
  const factory Enrollment({
    required String id,
    required String studentId,
    required String courseId,
    @Default(EnrollmentStatus.pending) EnrollmentStatus status,
    EnrollmentProgress? progress,
    EnrollmentProgressOverall? progressSummary,
    required String enrolledAt,
    String? updatedAt,
  }) = _Enrollment;

  factory Enrollment.fromJson(Map<String, dynamic> json) => _$EnrollmentFromJson(json);
}
