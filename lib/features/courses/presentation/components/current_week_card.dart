import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';

class CurrentWeekCard extends StatelessWidget {
  final Module? activeModule;
  final VoidCallback onContinue;

  const CurrentWeekCard({
    super.key,
    required this.activeModule,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    if (activeModule == null) return SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Study Week',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.stackMd),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.go('/courses/${activeModule!.courseId}/modules/${activeModule!.id}'),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.stackLg, 
                        right: AppDimensions.stackLg, 
                        top: AppDimensions.stackLg, 
                        bottom: AppDimensions.stackSm
                      ),
                      child: MergeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                  ),
                                  child: Text(
                                    'WEEK ${activeModule!.orderIndex + 1}',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                            SizedBox(height: AppDimensions.stackMd),
                            Text(
                              activeModule!.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppDimensions.stackSm),
                            Text(
                              activeModule!.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.stackLg, 
                      right: AppDimensions.stackLg, 
                      bottom: AppDimensions.stackLg
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.go('/courses/${activeModule!.courseId}/modules/${activeModule!.id}'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                      child: Text('Start Studying Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
