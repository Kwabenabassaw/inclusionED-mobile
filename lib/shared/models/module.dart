import 'package:freezed_annotation/freezed_annotation.dart';

part 'module.freezed.dart';
part 'module.g.dart';

enum ModuleStatus {
  @JsonValue('DRAFT') draft,
  @JsonValue('READY') ready,
  @JsonValue('PUBLISHED') published,
  @JsonValue('ARCHIVED') archived,
}

@freezed
abstract class Module with _$Module {
  const factory Module({
    required String id,
    required String courseId,
    required String title,
    required int weekNumber,
    required String description,
    required num orderIndex,
    required bool isPublished,
    required ModuleStatus status,
    required String createdAt,
    required String updatedAt,
  }) = _Module;

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);
}
