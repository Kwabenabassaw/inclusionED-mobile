import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
abstract class Course with _$Course {
  const factory Course({
    required String id,
    required String code,
    required String name,
    required String description,
    required String department,
    required String level,
    required String term,
    required bool published,
    required bool archived,
    @Default(0) int studentsCount,
    @Default(0) int accessibilityScore,
    required String createdAt,
    required String instructorId,
    String? imageUrl,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}
