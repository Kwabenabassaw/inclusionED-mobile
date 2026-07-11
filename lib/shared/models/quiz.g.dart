// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) =>
    _QuizQuestion(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      points: (json['points'] as num).toInt(),
      explanation: json['explanation'] as String?,
      altText: json['altText'] as String?,
      ttsReadout: json['ttsReadout'] as String?,
      explanationTtsReadout: json['explanationTtsReadout'] as String?,
    );

Map<String, dynamic> _$QuizQuestionToJson(_QuizQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'text': instance.text,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'points': instance.points,
      'explanation': instance.explanation,
      'altText': instance.altText,
      'ttsReadout': instance.ttsReadout,
      'explanationTtsReadout': instance.explanationTtsReadout,
    };

_Quiz _$QuizFromJson(Map<String, dynamic> json) => _Quiz(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  moduleId: json['moduleId'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  timeLimit: (json['timeLimit'] as num?)?.toInt() ?? 0,
  published: json['published'] as bool? ?? false,
  totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
  accessibilityScore: (json['accessibilityScore'] as num?)?.toInt(),
  questions: (json['questions'] as List<dynamic>)
      .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuizToJson(_Quiz instance) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'moduleId': instance.moduleId,
  'title': instance.title,
  'description': instance.description,
  'timeLimit': instance.timeLimit,
  'published': instance.published,
  'totalPoints': instance.totalPoints,
  'accessibilityScore': instance.accessibilityScore,
  'questions': instance.questions,
};
