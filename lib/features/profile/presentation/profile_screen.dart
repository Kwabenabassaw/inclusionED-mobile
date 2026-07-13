import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/shared/models/user_profile.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/accessibility/presentation/screen_reader_wrapper.dart';
import 'package:opencampus_lms/core/providers/voice_providers.dart';
import 'package:opencampus_lms/core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
          return const Scaffold(
            body: Center(child: Text('User profile not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildProfileHeader(context, userProfile),
                      const SizedBox(height: 24),
                      _buildTabBar(theme),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 520, // Constrain size to accommodate tab view items cleanly
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAccessibilityTab(context),
                            _buildSettingsTab(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
        tabs: const [
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.accessibility_new, size: 16),
                SizedBox(width: 6),
                Text('Accessibility'),
              ],
            ),
          ),
          Tab(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 16),
                SizedBox(width: 6),
                Text('System'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimaryContainer;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    backgroundImage: profile.avatar.isNotEmpty ? NetworkImage(profile.avatar) : null,
                    child: profile.avatar.isEmpty
                        ? Icon(Icons.person, size: 46, color: theme.colorScheme.primary)
                        : null,
                  ),
                ),
                if (_isUploadingAvatar)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () => _uploadAvatar(profile),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32, // Ensuring minimum touch target
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              profile.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 16,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildMetadataTile('Student ID', profile.studentId ?? profile.id, Icons.badge, onPrimary),
                  _buildMetadataTile('Faculty', profile.faculty ?? 'Science', Icons.account_balance, onPrimary),
                  _buildMetadataTile('Department', profile.department, Icons.lan, onPrimary),
                  _buildMetadataTile('Academic Level', profile.academicLevel ?? 'Undergraduate', Icons.school, onPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataTile(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
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
            ],
          ),
          const SizedBox(height: 12),
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
              _buildSwitchTile(
                leading: Icons.touch_app,
                title: 'In-App Screen Reader',
                subtitle: 'Tap items to hear them read aloud',
                value: settings.screenReaderEnabled,
                theme: theme,
                onChanged: (val) => notifier.toggleScreenReaderEnabled(),
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
            title: 'System & Security',
            icon: Icons.shield,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Sound and alerts preferences',
                theme: theme,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryCard(
            title: 'Account Settings',
            icon: Icons.manage_accounts,
            theme: theme,
            children: [
              _buildInteractiveTile(
                leading: Icons.edit,
                title: 'Edit Profile Details',
                subtitle: 'Change display name and information',
                theme: theme,
                onTap: () {},
              ),
              _buildInteractiveTile(
                leading: Icons.password,
                title: 'Change Password',
                subtitle: 'Secure your student credentials',
                theme: theme,
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(
                  'Logout',
                  style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  ref.read(authRepositoryProvider).signOut();
                },
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
    return SpeakOnTap(
      textToSpeak: '$title. $subtitle',
      onActivate: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
          ),
        ),
        child: ListTile(
          leading: Icon(leading, color: theme.colorScheme.onSurfaceVariant),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8))),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
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
    return SpeakOnTap(
      textToSpeak: subtitle != null ? '$title. $subtitle' : title,
      child: Container(
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
            ],
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.text_decrease),
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
              const Icon(Icons.text_increase),
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
