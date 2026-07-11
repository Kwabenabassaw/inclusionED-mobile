import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/quizzes/data/quiz_repository.dart';

class CourseTasksTab extends ConsumerWidget {
  final String courseId;
  final String? moduleId;

  const CourseTasksTab({
    super.key,
    required this.courseId,
    this.moduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (moduleId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginPage),
          child: Text('No active module found.'),
        ),
      );
    }

    final asyncQuizzes = ref.watch(moduleQuizzesProvider(moduleId!));

    return asyncQuizzes.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(child: Text('No upcoming quizzes.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
              child: ListTile(
                leading: Icon(
                  Icons.assignment_late,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(quiz.title, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text('${quiz.timeLimit} mins • ${quiz.totalPoints} pts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/courses/$courseId/quizzes/${quiz.id}');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading quizzes: $e')),
    );
  }
}
