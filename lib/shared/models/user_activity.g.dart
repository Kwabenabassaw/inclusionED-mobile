// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserHighlight _$UserHighlightFromJson(Map<String, dynamic> json) =>
    _UserHighlight(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      text: json['text'] as String,
      startIndex: (json['startIndex'] as num).toInt(),
      endIndex: (json['endIndex'] as num).toInt(),
      colorHex: json['colorHex'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserHighlightToJson(_UserHighlight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'courseId': instance.courseId,
      'text': instance.text,
      'startIndex': instance.startIndex,
      'endIndex': instance.endIndex,
      'colorHex': instance.colorHex,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_UserNote _$UserNoteFromJson(Map<String, dynamic> json) => _UserNote(
  id: json['id'] as String,
  lessonId: json['lessonId'] as String,
  courseId: json['courseId'] as String,
  title: json['title'] as String,
  content: json['content'] as String,
  anchoredText: json['anchoredText'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserNoteToJson(_UserNote instance) => <String, dynamic>{
  'id': instance.id,
  'lessonId': instance.lessonId,
  'courseId': instance.courseId,
  'title': instance.title,
  'content': instance.content,
  'anchoredText': instance.anchoredText,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_UserFlashcard _$UserFlashcardFromJson(Map<String, dynamic> json) =>
    _UserFlashcard(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String,
      masteryLevel: (json['masteryLevel'] as num).toInt(),
      nextReviewDate: json['nextReviewDate'] == null
          ? null
          : DateTime.parse(json['nextReviewDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserFlashcardToJson(_UserFlashcard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'courseId': instance.courseId,
      'question': instance.question,
      'answer': instance.answer,
      'category': instance.category,
      'masteryLevel': instance.masteryLevel,
      'nextReviewDate': instance.nextReviewDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
