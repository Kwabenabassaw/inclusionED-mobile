import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

void showDisplaySettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
              'Display Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                final settings = ref.watch(accessibilityProvider);
                final notifier = ref.read(accessibilityProvider.notifier);
                final theme = Theme.of(context);

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Font Size Slider
                        Text('Text Size', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.text_decrease, color: theme.colorScheme.onSurfaceVariant),
                            Expanded(
                              child: Slider(
                                value: settings.textScale,
                                min: 0.8,
                                max: 2.5,
                                divisions: 17,
                                label: '${(settings.textScale * 100).toInt()}%',
                                activeColor: theme.colorScheme.primary,
                                inactiveColor: theme.colorScheme.surfaceContainerHighest,
                                onChanged: (val) {
                                  notifier.setTextScale(val);
                                },
                              ),
                            ),
                            Icon(Icons.text_increase, color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: 24),
    
                        // Bold Text Toggle
                        SwitchListTile(
                          title: Text('Bold Text', style: theme.textTheme.titleMedium),
                          value: settings.boldText,
                          onChanged: (val) => notifier.toggleBoldText(),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
    
                        // Line Spacing
                        Text('Line Spacing', style: theme.textTheme.titleMedium),
                        Row(
                          children: [
                            Icon(Icons.format_line_spacing, color: theme.colorScheme.onSurfaceVariant),
                            Expanded(
                              child: Slider(
                                value: settings.lineSpacing,
                                min: 1.0,
                                max: 2.5,
                                divisions: 15,
                                label: '${settings.lineSpacing.toStringAsFixed(1)}x',
                                activeColor: theme.colorScheme.primary,
                                inactiveColor: theme.colorScheme.surfaceContainerHighest,
                                onChanged: (val) {
                                  notifier.setLineSpacing(val);
                                },
                              ),
                            ),
                            Text('${settings.lineSpacing.toStringAsFixed(1)}x', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 24),
    
                        // Font Style (Family)
                        Text('Font Style', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFontChip('System', 'System', settings.fontFamily, notifier),
                            _buildFontChip('Atkinson', 'Atkinson Hyperlegible', settings.fontFamily, notifier),
                            _buildFontChip('Serif', 'Georgia', settings.fontFamily, notifier),
                            _buildFontChip('Dyslexic', 'OpenDyslexic', settings.fontFamily, notifier),
                          ],
                        ),
                        const SizedBox(height: 24),
    
                        // Font Color (High Contrast / Themes)
                        Text('Color Theme', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildColorThemeCard(
                              title: 'Light',
                              bgColor: const Color(0xFFF5F5F5),
                              textColor: Colors.black,
                              isSelected: !settings.darkMode && !settings.highContrast,
                              onTap: () {
                                if (settings.highContrast) notifier.toggleHighContrast();
                                if (settings.darkMode) notifier.toggleDarkMode();
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildColorThemeCard(
                              title: 'Dark',
                              bgColor: const Color(0xFF1E1E1E),
                              textColor: Colors.white,
                              isSelected: settings.darkMode && !settings.highContrast,
                              onTap: () {
                                if (settings.highContrast) notifier.toggleHighContrast();
                                if (!settings.darkMode) notifier.toggleDarkMode();
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildColorThemeCard(
                              title: 'Contrast',
                              bgColor: Colors.black,
                              textColor: Colors.yellowAccent,
                              isSelected: settings.highContrast,
                              onTap: () {
                                if (!settings.highContrast) notifier.toggleHighContrast();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ));
    },
  );
}

Widget _buildFontChip(String label, String value, String currentValue, AccessibilityNotifier notifier) {
  final isSelected = currentValue == value || (currentValue == 'System' && value == 'System');
  return ChoiceChip(
    label: Text(label, style: TextStyle(fontFamily: value == 'System' ? null : value)),
    selected: isSelected,
    onSelected: (selected) {
      if (selected) notifier.setFontFamily(value);
    },
  );
}

Widget _buildColorThemeCard({
  required String title,
  required Color bgColor,
  required Color textColor,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
