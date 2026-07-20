import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/quizzes/data/quiz_repository.dart';
import 'package:opencampus_lms/features/assignments/data/assignment_repository.dart';

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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: Semantics(
            label: 'No active module found.',
            child: const Text('No active module found.'),
          ),
        ),
      );
    }

    final asyncQuizzes = ref.watch(moduleQuizzesProvider(moduleId!));
    final asyncAssignments = ref.watch(courseAssignmentsProvider(courseId));

    return asyncQuizzes.when(
      data: (quizzes) {
        return asyncAssignments.when(
          data: (assignments) {
            final hasTasks = quizzes.isNotEmpty || assignments.isNotEmpty;
            if (!hasTasks) {
              return Center(
                child: Semantics(
                  label: 'No upcoming tasks.',
                  child: const Text('No upcoming tasks.'),
                ),
              );
            }
            
            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.marginPage),
              children: [
                if (quizzes.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.stackSm),
                    child: Text('Quizzes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  ...quizzes.map((quiz) => Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
                    child: MergeSemantics(
                      child: ListTile(
                        leading: Icon(
                          Icons.quiz,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(quiz.title, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('${quiz.timeLimit} mins • ${quiz.totalPoints} pts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/courses/$courseId/quizzes/${quiz.id}');
                        },
                      ),
                    ),
                  )),
                ],
                if (assignments.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.stackLg, bottom: AppDimensions.stackSm),
                    child: Text('Assignments', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  ...assignments.map((assignment) => Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
                    child: MergeSemantics(
                      child: ListTile(
                        leading: Icon(
                          Icons.assignment,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        title: Text(assignment.title, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('Due: ${assignment.dueDate.split('T')[0]} • ${assignment.totalPoints} pts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/courses/$courseId/assignments/${assignment.id}');
                        },
                      ),
                    ),
                  )),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error loading assignments: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading quizzes: $e')),
    );
  }
}
