import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/quizzes/data/quiz_repository.dart';
import 'package:opencampus_lms/features/modules/presentation/quiz_screen.dart';

class QuizPlayerWrapper extends ConsumerWidget {
  final String courseId;
  final String quizId;

  const QuizPlayerWrapper({
    super.key,
    required this.courseId,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizProvider(quizId));

    return quizAsync.when(
      data: (quiz) {
        if (quiz == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Quiz Not Found')),
            body: Center(
              child: Semantics(
                label: 'This quiz could not be loaded.',
                child: Text('This quiz could not be loaded.'),
              ),
            ),
          );
        }
        return QuizScreen(courseId: courseId, quiz: quiz);
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Semantics(
            label: 'Failed to load quiz: $e',
            child: Text('Failed to load quiz: $e'),
          ),
        ),
      ),
    );
  }
}
