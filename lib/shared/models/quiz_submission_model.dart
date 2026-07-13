class QuizSubmission {
  final String userId;
  final String quizId;
  final Map<String, String> answers;
  final Map<String, bool> accommodationsUsed;
  final DateTime submittedAt;

  QuizSubmission({
    required this.userId,
    required this.quizId,
    required this.answers,
    required this.accommodationsUsed,
    required this.submittedAt,
  });

  factory QuizSubmission.fromJson(Map<String, dynamic> json) {
    return QuizSubmission(
      userId: json['userId'] as String,
      quizId: json['quizId'] as String,
      answers: Map<String, String>.from(json['answers'] as Map),
      accommodationsUsed: Map<String, bool>.from(json['accommodationsUsed'] as Map),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizId': quizId,
      'answers': answers,
      'accommodationsUsed': accommodationsUsed,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
