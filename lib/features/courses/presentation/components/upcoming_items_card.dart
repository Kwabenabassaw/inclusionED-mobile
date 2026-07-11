import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/quizzes/data/quiz_repository.dart';

class UpcomingItemsCard extends ConsumerWidget {
  final String courseId;
  final String? moduleId;
  final List<String> completedQuizIds;

  const UpcomingItemsCard({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.completedQuizIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (moduleId == null) return const SizedBox.shrink();

    final quizzesAsync = ref.watch(moduleQuizzesProvider(moduleId!));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Quizzes',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          quizzesAsync.when(
            data: (quizzes) {
              // Filter out quizzes that are already completed
              final incompleteQuizzes = quizzes
                  .where((quiz) => !completedQuizIds.contains(quiz.id))
                  .toList();

              if (incompleteQuizzes.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: incompleteQuizzes.map((quiz) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.stackSm),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      side: BorderSide(
                        color: theme.colorScheme.surfaceContainerHighest,
                        width: 1.5,
                      ),
                    ),
                    color: theme.colorScheme.surfaceContainerLowest,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.assignment_late_outlined, 
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          quiz.title, 
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${quiz.timeLimit} mins • ${quiz.totalPoints} points',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/courses/$courseId/quizzes/${quiz.id}');
                        },
                      ),
                    ),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading tasks: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.stackLg),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, size: 28, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'All caught up! No upcoming tasks for this module.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
