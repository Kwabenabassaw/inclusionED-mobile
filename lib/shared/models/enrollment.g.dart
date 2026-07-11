// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnrollmentProgress _$EnrollmentProgressFromJson(Map<String, dynamic> json) =>
    _EnrollmentProgress(
      completedModuleIds:
          (json['completedModuleIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedContentIds:
          (json['completedContentIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedQuizIds:
          (json['completedQuizIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EnrollmentProgressToJson(_EnrollmentProgress instance) =>
    <String, dynamic>{
      'completedModuleIds': instance.completedModuleIds,
      'completedContentIds': instance.completedContentIds,
      'completedQuizIds': instance.completedQuizIds,
    };

_EnrollmentProgressSummary _$EnrollmentProgressSummaryFromJson(
  Map<String, dynamic> json,
) => _EnrollmentProgressSummary(
  percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
  lastAccessedAt: json['lastAccessedAt'] as String?,
);

Map<String, dynamic> _$EnrollmentProgressSummaryToJson(
  _EnrollmentProgressSummary instance,
) => <String, dynamic>{
  'percentage': instance.percentage,
  'lastAccessedAt': instance.lastAccessedAt,
};

_EnrollmentProgressOverall _$EnrollmentProgressOverallFromJson(
  Map<String, dynamic> json,
) => _EnrollmentProgressOverall(
  overall: json['overall'] == null
      ? null
      : EnrollmentProgressSummary.fromJson(
          json['overall'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$EnrollmentProgressOverallToJson(
  _EnrollmentProgressOverall instance,
) => <String, dynamic>{'overall': instance.overall};

_Enrollment _$EnrollmentFromJson(Map<String, dynamic> json) => _Enrollment(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  courseId: json['courseId'] as String,
  status:
      $enumDecodeNullable(_$EnrollmentStatusEnumMap, json['status']) ??
      EnrollmentStatus.pending,
  progress: json['progress'] == null
      ? null
      : EnrollmentProgress.fromJson(json['progress'] as Map<String, dynamic>),
  progressSummary: json['progressSummary'] == null
      ? null
      : EnrollmentProgressOverall.fromJson(
          json['progressSummary'] as Map<String, dynamic>,
        ),
  enrolledAt: json['enrolledAt'] as String,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$EnrollmentToJson(_Enrollment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'courseId': instance.courseId,
      'status': _$EnrollmentStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'progressSummary': instance.progressSummary,
      'enrolledAt': instance.enrolledAt,
      'updatedAt': instance.updatedAt,
    };

const _$EnrollmentStatusEnumMap = {
  EnrollmentStatus.pending: 'PENDING',
  EnrollmentStatus.active: 'ACTIVE',
  EnrollmentStatus.rejected: 'REJECTED',
  EnrollmentStatus.completed: 'COMPLETED',
};
