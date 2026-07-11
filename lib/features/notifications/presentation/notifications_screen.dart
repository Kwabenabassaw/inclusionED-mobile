import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/authentication/data/auth_repository.dart';
import 'package:inclusive_ed_student/features/notifications/data/notification_repository.dart';
import 'package:inclusive_ed_student/shared/models/notification.dart' as app_model;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _formatTimeAgo(String createdAtStr) {
    try {
      final createdAt = DateTime.parse(createdAtStr);
      final diff = DateTime.now().difference(createdAt);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'just now';
    } catch (_) {
      return 'TBA';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final auth = ref.watch(authRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () async {
              final user = auth.currentUser;
              if (user == null) return;
              try {
                await ref.read(notificationRepositoryProvider).markAllAsRead(user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All notifications marked as read.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to mark all as read: $e'),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage, vertical: AppDimensions.stackMd),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                notification: notification,
                timeAgo: _formatTimeAgo(notification.createdAt),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            child: Text('Error loading notifications: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: theme.colorScheme.secondary),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              'All Caught Up',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'No new notifications at this moment.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final app_model.Notification notification;
  final String timeAgo;

  const _NotificationCard({
    required this.notification,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Customize based on notification type
    Color statusColor;
    IconData statusIcon;
    switch (notification.type.toUpperCase()) {
      case 'GRADE':
        statusColor = Colors.green;
        statusIcon = Icons.grade_outlined;
        break;
      case 'ANNOUNCEMENT':
        statusColor = Colors.orange;
        statusIcon = Icons.campaign_outlined;
        break;
      case 'ENROLLMENT':
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.school_outlined;
        break;
      default:
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.info_outline;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: notification.read 
              ? theme.colorScheme.surfaceContainerHighest 
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: notification.read ? 1.5 : 2.0,
        ),
      ),
      color: notification.read 
          ? theme.colorScheme.surfaceContainerLowest 
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: () async {
            // 1. Mark as read in backend
            if (!notification.read) {
              try {
                await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
              } catch (_) {}
            }

            // 2. Navigate based on type
            if (!context.mounted) return;
            switch (notification.type.toUpperCase()) {
              case 'GRADE':
              case 'ANNOUNCEMENT':
              case 'ENROLLMENT':
                context.go('/courses/${notification.referenceId}');
                break;
              default:
                context.go('/profile');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.stackLg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Wrapper
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.stackMd),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              notification.type.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: notification.read ? FontWeight.w600 : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread dot
                if (!notification.read) ...[
                  const SizedBox(width: AppDimensions.stackSm),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
