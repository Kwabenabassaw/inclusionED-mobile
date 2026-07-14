import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/shared/models/course.dart';
import 'package:opencampus_lms/core/widgets/glass_card.dart';

class CurrentCoursesList extends ConsumerWidget {
  const CurrentCoursesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCoursesAsync = ref.watch(activeCoursesProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Courses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/courses'),
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.stackSm),
        SizedBox(
          height: 240, // Increased height to fit cover images nicely
          child: activeCoursesAsync.when(
            data: (courses) {
              if (courses.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: AppDimensions.stackMd),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _buildCourseCard(context, course);
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 36,
            color: theme.colorScheme.secondary,
          ),
          SizedBox(height: 8),
          Text(
            'No active enrollments.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 200,
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: MergeSemantics(
          child: InkWell(
            onTap: () => context.go('/courses/${course.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Course Cover Image
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            course.imageUrl != null &&
                                course.imageUrl!.isNotEmpty
                            ? Image.network(
                                course.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderCover(context),
                              )
                            : _buildPlaceholderCover(context),
                      ),
                      // Accessibility Score badge on top of image
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.accessibility_new,
                                size: 12,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              SizedBox(width: 4),
                              Semantics(
                                label: 'Accessibility Score',
                                child: Text(
                                  '${course.accessibilityScore}%',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Course metadata
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.stackMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.code,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          course.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, child) {
                            final countAsync = ref.watch(courseStudentCountProvider(course.id));
                            // Fallback to the model's static count (0) while loading
                            final count = countAsync.asData?.value ?? course.studentsCount;
                            
                            return Row(
                              children: [
                                Icon(
                                  Icons.groups_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '$count students',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.book,
          size: 32,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
