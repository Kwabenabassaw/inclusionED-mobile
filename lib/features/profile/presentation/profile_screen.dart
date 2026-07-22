import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencampus_lms/features/gamification/data/gamification_repository.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/shared/models/user_profile.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

import 'package:opencampus_lms/core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';
import 'package:opencampus_lms/features/reader/data/user_activity_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  final List<String> _availableVoices = ['Joanna', 'Matthew', 'Amy', 'Brian', 'Ruth'];
  bool _isUploadingAvatar = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _uploadAvatar(UserProfile profile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final file = File(pickedFile.path);
      final fileExt = pickedFile.path.split('.').last;
      final fileName = '${profile.uid}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'avatars/$fileName';

      await Supabase.instance.client.storage
          .from('inclusive')
          .upload(filePath, file);

      final publicUrl = Supabase.instance.client.storage
          .from('inclusive')
          .getPublicUrl(filePath);

      await ref.read(authRepositoryProvider).updateUserProfile(profile.uid, {'avatar': publicUrl});
      
      ref.invalidate(userProfileProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading avatar: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile == null) {
          return Scaffold(
            body: Center(child: Text('User profile not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userProfileProvider);
                    // Add a small delay for UI feedback
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 8),
                        _buildProfileHeader(context, userProfile),
                        SizedBox(height: 24),
                        _buildTabBar(theme),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 520, // Constrain size to accommodate tab view items cleanly
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAccessibilityTab(context),
                              _buildSettingsTab(context),
                              _buildActivityTab(context),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
        tabs: const [
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.accessibility_new, size: 15),
                SizedBox(width: 2),
                Text('Accessibility'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 15),
                SizedBox(width: 2),
                Text('System'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 15),
                SizedBox(width: 2),
                Text('Badges & Notes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Avatar + Name ─────────────────────────────────────────────
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      backgroundImage: profile.avatar.isNotEmpty
                          ? NetworkImage(profile.avatar)
                          : null,
                      child: profile.avatar.isEmpty
                          ? Icon(Icons.person_rounded, size: 50, color: theme.colorScheme.primary)
                          : null,
                    ),
                  ),
                  if (_isUploadingAvatar)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _uploadAvatar(profile),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                profile.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // Student ID pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ID: ${profile.studentId ?? profile.id.substring(0, 8).toUpperCase()}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ── Info Grid ─────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                theme,
                icon: Icons.account_balance_outlined,
                label: 'Faculty',
                value: profile.faculty ?? 'Science',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                theme,
                icon: Icons.lan_outlined,
                label: 'Department',
                value: profile.department,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                theme,
                icon: Icons.school_outlined,
                label: 'Academic Level',
                value: profile.academicLevel ?? 'Undergraduate',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                theme,
                icon: Icons.calendar_month_outlined,
                label: 'Member Since',
                value: _formatMemberSince(profile),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatMemberSince(UserProfile profile) {
    try {
      // Try parsing from createdAt if available, otherwise show current year
      return DateTime.now().year.toString();
    } catch (_) {
      return '2024';
    }
  }

  Widget _buildInfoTile(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityTab(BuildContext context) {
    final settings = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryCard(
            title: 'Visual Options',
            icon: Icons.visibility,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.accessibility_new,
                title: 'Accessibility Profile',
                subtitle: _getPresetName(settings.preset),
                theme: theme,
                onTap: () => _showPresetSelectionBottomSheet(context, settings.preset, notifier),
              ),
              _buildInteractiveTile(
                leading: Icons.format_size,
                title: 'Font Size',
                subtitle: '${(settings.textScale * 100).toInt()}%',
                theme: theme,
                onTap: () => _showFontSizeBottomSheet(context, settings.textScale, notifier),
              ),
              _buildInteractiveTile(
                leading: Icons.font_download,
                title: 'Font Family',
                subtitle: settings.fontFamily,
                theme: theme,
                onTap: () => _showFontFamilyBottomSheet(context, settings.fontFamily, notifier),
              ),
              _buildSwitchTile(
                leading: Icons.contrast,
                title: 'High Contrast',
                value: settings.highContrast,
                theme: theme,
                onChanged: (val) => notifier.toggleHighContrast(),
              ),
              _buildSwitchTile(
                leading: Icons.dark_mode,
                title: 'Dark Mode',
                value: settings.darkMode,
                theme: theme,
                onChanged: (val) => notifier.toggleDarkMode(),
              ),
              _buildSwitchTile(
                leading: Icons.format_bold,
                title: 'Bold Text',
                subtitle: 'Makes all text heavier for easier reading',
                value: settings.boldText,
                theme: theme,
                onChanged: (val) => notifier.toggleBoldText(),
              ),
              _buildInteractiveTile(
                leading: Icons.format_line_spacing,
                title: 'Line Spacing',
                subtitle: '${settings.lineSpacing.toStringAsFixed(1)}x',
                theme: theme,
                onTap: () => _showLineSpacingBottomSheet(context, settings.lineSpacing, notifier),
              ),
              _buildSwitchTile(
                leading: Icons.highlight,
                title: 'Word Highlighting',
                subtitle: 'Highlight words as they are read aloud',
                value: settings.ttsHighlighting,
                theme: theme,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(ttsHighlighting: val)),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildCategoryCard(
            title: 'Speech & Reader',
            icon: Icons.volume_up,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.keyboard_voice,
                title: 'Voice Settings',
                subtitle: 'Configure speeds, pitches & voices',
                theme: theme,
                onTap: () => context.push('/profile/voice-settings'),
              ),

              _buildInteractiveTile(
                leading: Icons.menu_book,
                title: 'Accessible Reader Test',
                subtitle: 'Try the speech engine',
                theme: theme,
                onTap: () => context.push('/profile/accessible-reader'),
              ),
              _buildSwitchTile(
                leading: Icons.animation,
                title: 'Reduce Animations',
                value: settings.reduceMotion,
                theme: theme,
                onChanged: (val) => notifier.updateSettings(settings.copyWith(reduceMotion: val)),
              ),
              _buildInteractiveTile(
                leading: Icons.settings_accessibility,
                title: 'System Accessibility Settings',
                subtitle: 'Turn on TalkBack, Voice Access, etc.',
                theme: theme,
                onTap: () => AppSettings.openAppSettings(type: AppSettingsType.accessibility),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCategoryCard(
            title: 'Achievements & Activity',
            icon: Icons.emoji_events_outlined,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.military_tech_outlined,
                title: 'Achievements & Badges',
                subtitle: 'View your XP, streaks, level & badges',
                theme: theme,
                onTap: () => context.push('/achievements'),
              ),
              _buildInteractiveTile(
                leading: Icons.notes_rounded,
                title: 'My Saved Notes',
                subtitle: 'View all saved lesson notes & reflections',
                theme: theme,
                onTap: () {
                  _tabController.animateTo(2);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryCard(
            title: 'System & Security',
            icon: Icons.shield_outlined,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.app_settings_alt_outlined,
                title: 'System Notification Access',
                subtitle: 'Manage device-level app permissions',
                theme: theme,
                onTap: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
              ),
              _buildInteractiveTile(
                leading: Icons.notifications_active_outlined,
                title: 'In-App Notifications',
                subtitle: 'Manage which alerts you receive',
                theme: theme,
                onTap: () => context.push('/profile/notification-settings'),
              ),
              _buildInteractiveTile(
                leading: Icons.fingerprint_rounded,
                title: 'Biometric / Device Lock',
                subtitle: 'Secure login with fingerprint or face',
                theme: theme,
                onTap: () => AppSettings.openAppSettings(type: AppSettingsType.security),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryCard(
            title: 'Account Settings',
            icon: Icons.manage_accounts_outlined,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.edit_outlined,
                title: 'Edit Profile Details',
                subtitle: 'Change your display name and info',
                theme: theme,
                onTap: () {},
              ),
              _buildInteractiveTile(
                leading: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Secure your student credentials',
                theme: theme,
                onTap: () {},
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(Icons.logout_rounded, color: theme.colorScheme.onErrorContainer, size: 20),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Sign out of your account',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.error),
                onTap: () {
                  ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryCard(
            title: 'About',
            icon: Icons.info_outline_rounded,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Visit our FAQ or contact support',
                theme: theme,
                onTap: () {},
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(Icons.tag_rounded, color: theme.colorScheme.onSurfaceVariant),
                title: Text('App Version', style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    'v1.0.0',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildInteractiveTile({
    required IconData leading,
    required String title,
    required String subtitle,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
        ),
      ),
      child: ListTile(
        leading: Icon(leading, color: theme.colorScheme.onSurfaceVariant),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8))),
        trailing: Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData leading,
    required String title,
    String? subtitle,
    required bool value,
    required ThemeData theme,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(leading, color: theme.colorScheme.onSurfaceVariant),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8))) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(gamificationStreamProvider);
    final notesAsync = ref.watch(allUserNotesProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Gamification / Achievements Card
          _buildCategoryCard(
            title: 'Achievements & Badges',
            icon: Icons.emoji_events_rounded,
            theme: theme,
            children: [
              statsAsync.when(
                data: (stats) {
                  if (stats == null) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Start learning lessons to earn XP and unlock badges!'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.star_rounded, color: theme.colorScheme.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level ${stats.level} Scholar',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${stats.totalXp} Total XP • ${stats.currentStreak} Day Streak 🔥',
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () => context.push('/achievements'),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        if (stats.earnedBadgeIds.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('Unlocked Badges (${stats.earnedBadgeIds.length})', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: stats.earnedBadgeIds.map((badgeStr) {
                              final badgeId = BadgeId.values.firstWhere(
                                (b) => b.name == badgeStr,
                                orElse: () => BadgeId.firstLesson,
                              );
                              final def = kBadgeDefinitions[badgeId];
                              if (def == null) return const SizedBox.shrink();
                              return Chip(
                                avatar: Text(def.icon, style: const TextStyle(fontSize: 16)),
                                label: Text(def.name, style: const TextStyle(fontSize: 12)),
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading stats: $e'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // All Saved Notes Section
          _buildCategoryCard(
            title: 'My Saved Notes',
            icon: Icons.notes_rounded,
            theme: theme,
            children: [
              notesAsync.when(
                data: (notes) {
                  if (notes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.note_alt_outlined, size: 40, color: theme.colorScheme.outlineVariant),
                            const SizedBox(height: 8),
                            Text(
                              'No saved notes yet',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Notes you take in lessons will appear here.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.description_outlined, color: theme.colorScheme.onSecondaryContainer, size: 20),
                        ),
                        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (note.anchoredText != null)
                              Text(
                                '"${note.anchoredText!}"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.primary, fontSize: 12),
                              ),
                            Text(
                              note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () {
                            ref.read(userActivityRepositoryProvider).deleteNote(note.id);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading notes: $e'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFontSizeBottomSheet(BuildContext context, double currentScale, AccessibilityNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _FontSizeBottomSheet(initialScale: currentScale, notifier: notifier);
      },
    );
  }

  void _showFontFamilyBottomSheet(BuildContext context, String currentFont, AccessibilityNotifier notifier) {
    final fonts = ['Atkinson Hyperlegible', 'OpenDyslexic', 'Roboto', 'Lexend'];
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Font Family', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ...fonts.map((font) {
                return RadioListTile<String>(
                  title: Text(
                    font,
                    style: TextStyle(fontFamily: font == 'Roboto' ? null : font),
                  ),
                  value: font,
                  groupValue: currentFont,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setFontFamily(value);
                      Navigator.pop(context);
                    }
                  },
                );
              }),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLineSpacingBottomSheet(BuildContext context, double currentSpacing, AccessibilityNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _LineSpacingBottomSheet(initialSpacing: currentSpacing, notifier: notifier);
      },
    );
  }

  String _getPresetName(AccessibilityPreset preset) {
    switch (preset) {
      case AccessibilityPreset.standard:
        return 'Standard (Default)';
      case AccessibilityPreset.dyslexia:
        return 'Dyslexia / Cognitive Focus';
      case AccessibilityPreset.visualImpairment:
        return 'Visual Impairment (Low Vision)';
      case AccessibilityPreset.motorDifficulty:
        return 'Motor Difficulty Focus';
    }
  }

  void _showPresetSelectionBottomSheet(BuildContext context, AccessibilityPreset currentPreset, AccessibilityNotifier notifier) {
    final theme = Theme.of(context);
    final presets = [
      AccessibilityPreset.standard,
      AccessibilityPreset.dyslexia,
      AccessibilityPreset.visualImpairment,
      AccessibilityPreset.motorDifficulty,
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Accessibility Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...presets.map((preset) {
                    return RadioListTile<AccessibilityPreset>(
                      title: Text(_getPresetName(preset)),
                      value: preset,
                      groupValue: currentPreset,
                      onChanged: (value) {
                        if (value != null) {
                          notifier.applyPreset(value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FontSizeBottomSheet extends StatefulWidget {
  final double initialScale;
  final AccessibilityNotifier notifier;

  const _FontSizeBottomSheet({required this.initialScale, required this.notifier});

  @override
  State<_FontSizeBottomSheet> createState() => _FontSizeBottomSheetState();
}

class _LineSpacingBottomSheet extends StatefulWidget {
  final double initialSpacing;
  final AccessibilityNotifier notifier;

  const _LineSpacingBottomSheet({required this.initialSpacing, required this.notifier});

  @override
  State<_LineSpacingBottomSheet> createState() => _LineSpacingBottomSheetState();
}

class _LineSpacingBottomSheetState extends State<_LineSpacingBottomSheet> {
  late double _currentSpacing;

  @override
  void initState() {
    super.initState();
    _currentSpacing = widget.initialSpacing;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line Spacing', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('${_currentSpacing.toStringAsFixed(1)}x', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(
              'This is a preview of how your reading content will be spaced. Comfortable spacing reduces eye strain and helps with reading flow.',
              style: theme.textTheme.bodyMedium?.copyWith(
                height: _currentSpacing,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.density_small),
              Expanded(
                child: Slider(
                  value: _currentSpacing,
                  min: 1.0,
                  max: 2.0,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() => _currentSpacing = value);
                    widget.notifier.setLineSpacing(value);
                  },
                ),
              ),
              const Icon(Icons.density_large),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save & Apply'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FontSizeBottomSheetState extends State<_FontSizeBottomSheet> {
  late double _currentScale;

  @override
  void initState() {
    super.initState();
    _currentScale = widget.initialScale;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Font Size', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text('${(_currentScale * 100).toInt()}%', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                'This is a preview of the text size.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16 * _currentScale,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.text_decrease),
              Expanded(
                child: Slider(
                  value: _currentScale,
                  min: 0.8,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (value) {
                    setState(() => _currentScale = value);
                    widget.notifier.setTextScale(value);
                  },
                ),
              ),
              Icon(Icons.text_increase),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Save & Apply'),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
