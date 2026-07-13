import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/shared/models/module.dart';

class CourseModulesTab extends ConsumerWidget {
  final String courseId;

  const CourseModulesTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncModules = ref.watch(courseModulesProvider(courseId));
    final asyncEnrollment = ref.watch(activeEnrollmentStreamProvider(courseId));

    return asyncModules.when(
      data: (modules) {
        if (modules.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No modules available yet.'),
            ),
          );
        }

        final enrollment = asyncEnrollment.asData?.value;
        final completedModuleIds = enrollment?.progress?.completedModuleIds ?? [];

        // Find the index of the first uncompleted module. That is the 'Current' one.
        int currentIdx = modules.indexWhere((m) => !completedModuleIds.contains(m.id));
        if (currentIdx == -1) currentIdx = modules.length;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            final isCompleted = index < currentIdx;
            final isCurrent = index == currentIdx;
            final isLocked = index > currentIdx;

            return _ModuleTimelineCard(
              courseId: courseId,
              module: module,
              index: index,
              totalCount: modules.length,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
              completedContentIds: enrollment?.progress?.completedContentIds ?? [],
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading timeline: $e'),
        ),
      ),
    );
  }
}

class _ModuleTimelineCard extends ConsumerWidget {
  final String courseId;
  final Module module;
  final int index;
  final int totalCount;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final List<String> completedContentIds;

  const _ModuleTimelineCard({
    required this.courseId,
    required this.module,
    required this.index,
    required this.totalCount,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLocked,
    required this.completedContentIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(moduleContentsProvider((courseId: courseId, moduleId: module.id)));
    final theme = Theme.of(context);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isCompleted) {
      statusColor = Colors.green;
      statusText = 'Completed';
      statusIcon = Icons.check_circle_outline;
    } else if (isCurrent) {
      statusColor = theme.colorScheme.primary;
      statusText = 'Current';
      statusIcon = Icons.play_circle_outline;
    } else {
      statusColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
      statusText = 'Locked';
      statusIcon = Icons.lock_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical timeline line with dot
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? theme.colorScheme.primaryContainer 
                      : isCompleted 
                          ? Colors.green.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  statusIcon,
                  size: 18,
                  color: statusColor,
                ),
              ),
              if (index < totalCount - 1)
                Container(
                  width: 2,
                  height: 120, // tall line for card height alignment
                  color: isCompleted ? Colors.green : theme.colorScheme.surfaceContainerHighest,
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.stackMd),
          
          // Card representing the Module Journey step
          Expanded(
            child: Card(
              elevation: isCurrent ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                side: BorderSide(
                  color: isCurrent 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.surfaceContainerHighest,
                  width: isCurrent ? 2.0 : 1.5,
                ),
              ),
              color: isLocked 
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceContainerLowest,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: InkWell(
                  onTap: isLocked 
                      ? null 
                      : () => context.go('/courses/$courseId/modules/${module.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.stackLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'WEEK ${module.orderIndex + 1}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : isCurrent 
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                              ),
                              child: Text(
                                statusText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.stackSm),
                        Text(
                          module.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked 
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.6) 
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          module.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        
                        // Show progress if active or completed
                        if (!isLocked) ...[
                          const SizedBox(height: AppDimensions.stackLg),
                          contentsAsync.when(
                            data: (contents) {
                              if (contents.isEmpty) return const SizedBox.shrink();
                              final completedCount = contents.where((c) => completedContentIds.contains(c?.id)).length;
                              final progress = completedCount / contents.length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Module Progress',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$completedCount/${contents.length} steps',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                                    color: isCompleted ? Colors.green : theme.colorScheme.primary,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ],
                              );
                            },
                            loading: () => const LinearProgressIndicator(minHeight: 2),
                            error: (err, stack) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppDimensions.stackLg),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/courses/$courseId/reader/${module.id}'),
                            icon: const Icon(Icons.accessibility_new),
                            label: const Text('Accessible Reader'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
