import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/courses/data/course_repository.dart';
import 'package:inclusive_ed_student/features/modules/data/module_repository.dart';
import 'package:inclusive_ed_student/shared/models/course.dart';
import 'package:inclusive_ed_student/shared/models/module.dart';
import 'package:inclusive_ed_student/shared/models/enrollment.dart';

class ActiveLearningCard extends ConsumerWidget {
  const ActiveLearningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCoursesAsync = ref.watch(activeCoursesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Continue Learning',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.stackMd),
        activeCoursesAsync.when(
          data: (courses) {
            if (courses.isEmpty) {
              return _buildEmptyState(context);
            }
            final course = courses.first;
            return _ActiveCourseLoader(course: course);
          },
          loading: () => _buildSkeleton(context),
          error: (err, stack) => _buildErrorState(context, err.toString()),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: theme.colorScheme.surfaceContainerHighest, width: 1.5),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.stackLg),
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              'Ready to Start?',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              'Find and enroll in accessible courses from our catalog to begin learning.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppDimensions.stackLg),
            ElevatedButton(
              onPressed: () => context.go('/courses'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text('Explore Catalog'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
      child: Container(
        height: 240,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.stackLg),
        child: Text('Error loading progress: $error'),
      ),
    );
  }
}

class _ActiveCourseLoader extends ConsumerWidget {
  final Course course;

  const _ActiveCourseLoader({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentAsync = ref.watch(activeEnrollmentStreamProvider(course.id));
    final modulesAsync = ref.watch(courseModulesProvider(course.id));

    return enrollmentAsync.when(
      data: (Enrollment? enrollment) {
        if (enrollment == null) return const SizedBox();
        
        return modulesAsync.when(
          data: (modules) {
            if (modules.isEmpty) {
              return _buildNoModulesCard(context);
            }

            final progress = enrollment.progress;
            final completedModuleIds = progress?.completedModuleIds ?? [];

            // Get first incomplete module, or fallback to the last module
            final activeModule = modules.firstWhere(
              (m) => !completedModuleIds.contains(m.id),
              orElse: () => modules.last,
            );

            return _ActiveModuleCard(
              course: course,
              module: activeModule,
              completedContentIds: progress?.completedContentIds ?? [],
            );
          },
          loading: () => const SizedBox(height: 240, child: Card(child: Center(child: CircularProgressIndicator()))),
          error: (err, stack) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Modules Error: $err'))),
        );
      },
      loading: () => const SizedBox(height: 240, child: Card(child: Center(child: CircularProgressIndicator()))),
      error: (err, stack) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Enrollment Error: $err'))),
    );
  }

  Widget _buildNoModulesCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: theme.colorScheme.surfaceContainerHighest),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.stackLg),
        child: Text(
          'No modules available for ${course.name} yet.',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _ActiveModuleCard extends ConsumerWidget {
  final Course course;
  final Module module;
  final List<String> completedContentIds;

  const _ActiveModuleCard({
    required this.course,
    required this.module,
    required this.completedContentIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(moduleContentsProvider((courseId: course.id, moduleId: module.id)));
    final theme = Theme.of(context);

    return contentsAsync.when(
      data: (contents) {
        double progress = 0.0;
        int completedCount = 0;
        if (contents.isNotEmpty) {
          completedCount = contents.where((c) => completedContentIds.contains(c.id)).length;
          progress = completedCount / contents.length;
        }

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            side: BorderSide(
              color: theme.colorScheme.surfaceContainerHighest,
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            onTap: () {
              context.go('/courses/${course.id}/modules/${module.id}');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Image / Background
                if (course.imageUrl != null && course.imageUrl!.isNotEmpty)
                  Image.network(
                    course.imageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderBanner(context),
                  )
                else
                  _buildPlaceholderBanner(context),
                
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.stackLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.stackSm),
                      Text(
                        module.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.stackSm),
                      Text(
                        module.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.stackLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}% Completed',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$completedCount/${contents.length} items',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.stackSm),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        color: theme.colorScheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 240, child: Card(child: Center(child: CircularProgressIndicator()))),
      error: (err, stack) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Contents Error: $err'))),
    );
  }

  Widget _buildPlaceholderBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.school, size: 48, color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }
}
