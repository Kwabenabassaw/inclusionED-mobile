import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);
    final isHighContrast = settings.highContrast;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to OpenCampus LMS',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: settings.fontFamily,
                  height: settings.lineSpacing,
                ),
                textScaler: TextScaler.linear(settings.textScale),
              ),
              SizedBox(height: 8),
              Text(
                'How would you like to experience the app today? You can always change this later in Settings.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: settings.fontFamily,
                  height: settings.lineSpacing,
                ),
                textScaler: TextScaler.linear(settings.textScale),
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _PresetCard(
                      title: 'Standard (Default)',
                      icon: Icons.check_circle_outline,
                      isSelected: settings.preset == AccessibilityPreset.standard,
                      isHighContrast: isHighContrast,
                      onTap: () => ref.read(accessibilityProvider.notifier).applyPreset(AccessibilityPreset.standard),
                      settings: settings,
                    ),
                    _PresetCard(
                      title: 'Dyslexia / Cognitive Focus',
                      icon: Icons.text_format,
                      isSelected: settings.preset == AccessibilityPreset.dyslexia,
                      isHighContrast: isHighContrast,
                      onTap: () => ref.read(accessibilityProvider.notifier).applyPreset(AccessibilityPreset.dyslexia),
                      settings: settings,
                    ),
                    _PresetCard(
                      title: 'Visual Impairment (Low Vision)',
                      icon: Icons.visibility,
                      isSelected: settings.preset == AccessibilityPreset.visualImpairment,
                      isHighContrast: isHighContrast,
                      onTap: () => ref.read(accessibilityProvider.notifier).applyPreset(AccessibilityPreset.visualImpairment),
                      settings: settings,
                    ),
                    _PresetCard(
                      title: 'Motor Difficulty Focus',
                      icon: Icons.touch_app,
                      isSelected: settings.preset == AccessibilityPreset.motorDifficulty,
                      isHighContrast: isHighContrast,
                      onTap: () => ref.read(accessibilityProvider.notifier).applyPreset(AccessibilityPreset.motorDifficulty),
                      settings: settings,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/onboarding'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16 + settings.touchTargetMargin),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to App',
                  style: TextStyle(
                    fontSize: 16 * settings.textScale,
                    fontWeight: FontWeight.bold,
                    fontFamily: settings.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isHighContrast;
  final VoidCallback onTap;
  final AccessibilitySettings settings;

  const _PresetCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isHighContrast,
    required this.onTap,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: 'Accessibility preset: $title',
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16 + settings.touchTargetMargin),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected 
                    ? (Theme.of(context).colorScheme.primary)
                    : (Theme.of(context).colorScheme.outlineVariant),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? (Theme.of(context).colorScheme.primary)
                      : (Theme.of(context).colorScheme.onSurface),
                  size: 24 * settings.textScale,
                ),
                SizedBox(width: 16 * settings.textScale),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: settings.fontFamily,
                    ),
                    textScaler: TextScaler.linear(settings.textScale),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24 * settings.textScale,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
