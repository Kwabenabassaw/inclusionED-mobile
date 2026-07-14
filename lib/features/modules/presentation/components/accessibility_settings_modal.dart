import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

class AccessibilitySettingsModal extends ConsumerWidget {
  const AccessibilitySettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(accessibilityProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.marginPage),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: AppDimensions.stackMd),
            Text('Text Size', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: AppDimensions.stackSm),
            Row(
              children: [
                Text('A', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Slider(
                    value: settings.textScale,
                    min: 0.8,
                    max: 2.0,
                    divisions: 6,
                    label: '${(settings.textScale * 100).toInt()}%',
                    onChanged: (value) {
                      ref.read(accessibilityProvider.notifier).setTextScale(value);
                    },
                  ),
                ),
                Text('A', style: TextStyle(fontSize: 24)),
              ],
            ),
            SizedBox(height: AppDimensions.stackLg),
            SwitchListTile(
              title: Text('High Contrast Mode'),
              subtitle: Text('Increases contrast for better readability'),
              value: settings.highContrast,
              onChanged: (value) {
                ref.read(accessibilityProvider.notifier).toggleHighContrast();
              },
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: AppDimensions.stackLg),
          ],
        ),
      ),
    );
  }
}
