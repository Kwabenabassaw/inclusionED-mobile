import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/features/notifications/data/notification_repository.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/shared/models/notification.dart' as app_model;

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
      data: (notifications) => (notifications as List<app_model.Notification>).where((n) => n.read == false).length,
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
        // Dark Mode Toggle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: child.key == const ValueKey('icon_dark') 
                ? Tween<double>(begin: 0.5, end: 1.0).animate(anim) 
                : Tween<double>(begin: -0.5, end: 0.0).animate(anim),
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: IconButton(
            key: ValueKey(ref.watch(accessibilityProvider).darkMode ? 'icon_dark' : 'icon_light'),
            onPressed: () => ref.read(accessibilityProvider.notifier).toggleDarkMode(),
            tooltip: ref.watch(accessibilityProvider).darkMode ? 'Switch to light mode' : 'Switch to dark mode',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            icon: Icon(
              ref.watch(accessibilityProvider).darkMode ? Icons.light_mode : Icons.dark_mode_outlined,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.stackMd),
        // Notification bell routing to /notifications
        IconButton(
          onPressed: () => context.go('/notifications'),
          tooltip: 'Notifications, $unreadCount unread',
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
        Semantics(
          label: 'User Profile',
          button: true,
          child: InkWell(
            onTap: () => context.go('/profile'),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: ExcludeSemantics(
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
          ),
        ),
      ],
    );
  }
}
