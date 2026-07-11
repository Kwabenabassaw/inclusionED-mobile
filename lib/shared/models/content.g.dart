// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GeneratedAltText _$GeneratedAltTextFromJson(Map<String, dynamic> json) =>
    _GeneratedAltText(
      id: json['id'] as String,
      imageLabel: json['imageLabel'] as String,
      suggestedAlt: json['suggestedAlt'] as String,
    );

Map<String, dynamic> _$GeneratedAltTextToJson(_GeneratedAltText instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageLabel': instance.imageLabel,
      'suggestedAlt': instance.suggestedAlt,
    };

_ContentBlock _$ContentBlockFromJson(Map<String, dynamic> json) =>
    _ContentBlock(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String?,
      content: json['content'],
      metadata: json['metadata'] as Map<String, dynamic>?,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$ContentBlockToJson(_ContentBlock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
      'metadata': instance.metadata,
      'order': instance.order,
    };

_Content _$ContentFromJson(Map<String, dynamic> json) => _Content(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  moduleId: json['moduleId'] as String,
  title: json['title'] as String,
  type: json['type'] as String,
  text: json['text'] as String?,
  fileName: json['fileName'] as String?,
  fileUrl: json['fileUrl'] as String?,
  fileSize: json['fileSize'] as String?,
  linkUrl: json['linkUrl'] as String?,
  status: json['status'] as String,
  contentMarkdown: json['contentMarkdown'] as String?,
  altTextsGenerated: (json['altTextsGenerated'] as List<dynamic>?)
      ?.map((e) => GeneratedAltText.fromJson(e as Map<String, dynamic>))
      .toList(),
  accessibilityScore: (json['accessibilityScore'] as num?)?.toInt() ?? 0,
  warnings: (json['warnings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  uploadedAt: json['uploadedAt'] as String?,
  blocks: (json['blocks'] as List<dynamic>?)
      ?.map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ContentToJson(_Content instance) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'moduleId': instance.moduleId,
  'title': instance.title,
  'type': instance.type,
  'text': instance.text,
  'fileName': instance.fileName,
  'fileUrl': instance.fileUrl,
  'fileSize': instance.fileSize,
  'linkUrl': instance.linkUrl,
  'status': instance.status,
  'contentMarkdown': instance.contentMarkdown,
  'altTextsGenerated': instance.altTextsGenerated,
  'accessibilityScore': instance.accessibilityScore,
  'warnings': instance.warnings,
  'uploadedAt': instance.uploadedAt,
  'blocks': instance.blocks,
};
