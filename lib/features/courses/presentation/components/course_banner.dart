import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/course.dart';

class CourseBanner extends StatelessWidget {
  final Course course;
  final double progressPercent;
  final String? currentModuleId;

  const CourseBanner({
    super.key,
    required this.course,
    this.progressPercent = 0.0,
    this.currentModuleId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = course.imageUrl != null && course.imageUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasImage ? Colors.black : theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXl),
          bottomRight: Radius.circular(AppDimensions.radiusXl),
        ),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(course.imageUrl!),
                fit: BoxFit.cover,
                opacity: 0.55, // darkened overlay for accessible high-contrast white text
              )
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.marginPage,
        AppDimensions.marginPage,
        AppDimensions.marginPage,
        AppDimensions.marginPage + 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hasImage
                  ? Colors.white.withValues(alpha: 0.2)
                  : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              course.term.toUpperCase(),
              style: TextStyle(
                color: hasImage ? Colors.white : theme.colorScheme.onPrimaryContainer,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppDimensions.stackMd),
          Text(
            course.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: hasImage ? Colors.white : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppDimensions.stackSm),
          Text(
            'DEPARTMENT OF ${course.department.toUpperCase()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasImage 
                  ? Colors.white.withValues(alpha: 0.8) 
                  : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: AppDimensions.stackXl),
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Class Progress',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: hasImage ? Colors.white : theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(progressPercent * 100).toInt()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: hasImage ? Colors.white : theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.stackSm),
                Semantics(
                  label: 'Course Progress',
                  value: '${(progressPercent * 100).toInt()} percent',
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.stackLg),
          if (currentModuleId != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/courses/${course.id}/modules/$currentModuleId');
                },
                icon: Icon(Icons.play_arrow, size: 20),
                label: Text('Continue Study Journey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasImage ? Colors.white : theme.colorScheme.onPrimaryContainer,
                  foregroundColor: hasImage ? Colors.black : theme.colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
