import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/shared/models/course.dart';

class CourseOverviewTab extends ConsumerWidget {
  final Course course;

  const CourseOverviewTab({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentAsync = ref.watch(activeEnrollmentStreamProvider(course.id));
    final modulesAsync = ref.watch(courseModulesProvider(course.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.marginPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course Description', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.stackSm),
          Text(course.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppDimensions.stackXl),
          
          Text('Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.stackSm),
          _buildDetailRow(context, 'Code', course.code),
          _buildDetailRow(context, 'Department', course.department),
          _buildDetailRow(context, 'Level', course.level),
          _buildDetailRow(context, 'Term', course.term),
          _buildDetailRow(context, 'Enrolled Students', '${course.studentsCount}'),
          
          const SizedBox(height: AppDimensions.stackXl),
          
          // Render progress logic if both are loaded
          if (enrollmentAsync.hasValue && modulesAsync.hasValue) ...[
            Builder(
              builder: (context) {
                final enrollment = enrollmentAsync.value;
                final modules = modulesAsync.value ?? [];
                final totalModules = modules.length;
                final completedModules = enrollment?.progress?.completedModuleIds.length ?? 0;
                final progress = totalModules > 0 ? (completedModules / totalModules) : 0.0;

                return Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.stackLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onPrimaryContainer),
                            const SizedBox(width: AppDimensions.stackSm),
                            Text(
                              'Your Progress',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.stackMd),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          minHeight: 8,
                        ),
                        const SizedBox(height: AppDimensions.stackSm),
                        Text(
                          '${(progress * 100).toInt()}% Completed',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ] else ...[
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.stackLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
