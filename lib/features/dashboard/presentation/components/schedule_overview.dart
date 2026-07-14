import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';
import 'package:opencampus_lms/core/widgets/glass_card.dart';

class ScheduleOverview extends ConsumerWidget {
  const ScheduleOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Schedule',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/calendar'),
              child: Text(
                'UPCOMING',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.stackMd),
        upcomingEventsAsync.when(
          data: (events) {
            if (events.isEmpty) {
              return _buildEmptyState(context);
            }
            final event = events.first; // just showing one for overview
            
            String formattedTime = 'TBA';
            try {
              final date = DateTime.parse(event.startDate);
              final amPm = date.hour >= 12 ? 'PM' : 'AM';
              final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
              final minute = date.minute.toString().padLeft(2, '0');
              formattedTime = '$hour:$minute\n$amPm';
            } catch (_) {}

            return GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: AppDimensions.radiusLg,
              child: MergeSemantics(
                child: InkWell(
                  onTap: () => context.go('/calendar'),
                  child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.stackLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon Box
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.event_note, 
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppDimensions.stackMd),
                              // Title and Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      event.type.toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: AppDimensions.stackSm),
                              // Time Badge
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    formattedTime,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.stackLg),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => context.go('/calendar'),
                                  icon: Icon(Icons.calendar_month, size: 18),
                                  label: Text('View Calendar'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppDimensions.radiusLg,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.stackLg),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 36, color: theme.colorScheme.secondary),
            SizedBox(height: 8),
            Text(
              'No class events scheduled for today.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
