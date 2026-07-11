import 'package:freezed_annotation/freezed_annotation.dart';

part 'content.freezed.dart';
part 'content.g.dart';

@freezed
abstract class GeneratedAltText with _$GeneratedAltText {
  const factory GeneratedAltText({
    required String id,
    required String imageLabel,
    required String suggestedAlt,
  }) = _GeneratedAltText;

  factory GeneratedAltText.fromJson(Map<String, dynamic> json) => _$GeneratedAltTextFromJson(json);
}

@freezed
abstract class ContentBlock with _$ContentBlock {
  const factory ContentBlock({
    required String id,
    required String type,
    String? title,
    dynamic content,
    Map<String, dynamic>? metadata,
    required int order,
  }) = _ContentBlock;

  factory ContentBlock.fromJson(Map<String, dynamic> json) => _$ContentBlockFromJson(json);
}

@freezed
abstract class Content with _$Content {
  const factory Content({
    required String id,
    required String courseId,
    required String moduleId,
    required String title,
    required String type,
    String? text,
    String? fileName,
    String? fileUrl,
    String? fileSize,
    String? linkUrl,
    required String status,
    String? contentMarkdown,
    List<GeneratedAltText>? altTextsGenerated,
    @Default(0) int accessibilityScore,
    List<String>? warnings,
    String? uploadedAt,
    List<ContentBlock>? blocks,
  }) = _Content;

  factory Content.fromJson(Map<String, dynamic> json) => _$ContentFromJson(json);
}
