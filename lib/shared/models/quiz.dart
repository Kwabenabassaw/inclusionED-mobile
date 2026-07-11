import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz.freezed.dart';
part 'quiz.g.dart';

@freezed
abstract class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    required String type, // 'multiple-choice', 'short-answer', 'TRUE_FALSE', 'FILL_BLANK'
    required String text,
    List<String>? options,
    required String correctAnswer,
    required int points,
    String? explanation,
    String? altText,
    String? ttsReadout,
    String? explanationTtsReadout,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => _$QuizQuestionFromJson(json);
}

@freezed
abstract class Quiz with _$Quiz {
  const factory Quiz({
    required String id,
    required String courseId,
    String? moduleId,
    required String title,
    required String description,
    @Default(0) int timeLimit,
    @Default(false) bool published,
    @Default(0) int totalPoints,
    int? accessibilityScore,
    required List<QuizQuestion> questions,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
}
