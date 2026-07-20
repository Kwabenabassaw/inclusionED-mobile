import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_activity.freezed.dart';
part 'user_activity.g.dart';

@freezed
abstract class UserHighlight with _$UserHighlight {
  const factory UserHighlight({
    required String id,
    required String lessonId,
    required String courseId,
    required String text, // The highlighted text
    required int startIndex, // Position in the markdown block
    required int endIndex,
    required String colorHex, // e.g. '#FFFF00'
    String? note, // Optional user note on this highlight
    required DateTime createdAt,
  }) = _UserHighlight;

  factory UserHighlight.fromJson(Map<String, dynamic> json) => _$UserHighlightFromJson(json);
}

@freezed
abstract class UserNote with _$UserNote {
  const factory UserNote({
    required String id,
    required String lessonId,
    required String courseId,
    required String title,
    required String content,
    String? anchoredText,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserNote;

  factory UserNote.fromJson(Map<String, dynamic> json) => _$UserNoteFromJson(json);
}

@freezed
abstract class UserFlashcard with _$UserFlashcard {
  const factory UserFlashcard({
    required String id,
    required String lessonId,
    required String courseId,
    required String question,
    required String answer,
    required String category,
    required int masteryLevel, // 0: New, 1: Learning, 2: Reviewing, 3: Mastered
    DateTime? nextReviewDate, // For spaced repetition
    required DateTime createdAt,
  }) = _UserFlashcard;

  factory UserFlashcard.fromJson(Map<String, dynamic> json) => _$UserFlashcardFromJson(json);
}
