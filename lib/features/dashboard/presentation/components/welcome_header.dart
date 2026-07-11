import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/authentication/data/auth_repository.dart';
import 'package:inclusive_ed_student/features/notifications/data/notification_repository.dart';

class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final displayName = user?.displayName ?? 'Alex';
    final theme = Theme.of(context);
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = notificationsAsync.when(
      data: (notifications) => notifications.where((n) => !n.read).length,
      loading: () => 0,
      error: (err, stack) => 0,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting & Welcome Message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()},',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  fontSize: 30,
                  letterSpacing: -0.5,
                ),
                semanticsLabel: 'Hello, $displayName',
              ),
            ],
          ),
        ),
        // Notification bell routing to /notifications
        IconButton(
          onPressed: () => context.go('/notifications'),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            backgroundColor: theme.colorScheme.error,
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.stackMd),
        // Profile initials avatar routing to /profile
        InkWell(
          onTap: () => context.go('/profile'),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initials,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
