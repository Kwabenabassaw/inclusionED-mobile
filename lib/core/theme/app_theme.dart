import 'package:flutter/material.dart';
import 'package:opencampus_lms/core/theme/app_colors.dart';
import 'package:opencampus_lms/core/theme/app_typography.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

class AppTheme {
  static ThemeData getTheme(AccessibilitySettings settings) {
    ColorScheme colorScheme;
    
    if (settings.darkMode && settings.highContrast) {
      colorScheme = highContrastDarkColorScheme;
    } else if (settings.darkMode) {
      colorScheme = darkColorScheme;
    } else if (settings.highContrast) {
      colorScheme = highContrastLightColorScheme;
    } else {
      colorScheme = lightColorScheme;
    }

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: AppTypography.getTextTheme(settings),
      scaffoldBackgroundColor: colorScheme.surface,
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(AppDimensions.touchTargetMin, 56), // Height: 56px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 16px
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(AppDimensions.touchTargetMin, 56),
          side: BorderSide(color: colorScheme.onSurfaceVariant, width: 2), // 2px charcoal border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface, 
        constraints: const BoxConstraints(minHeight: 56), // 56px height
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: colorScheme.onSurface, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: colorScheme.onSurface, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: colorScheme.primary, width: 3), // 3px Focus Gold ring
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide(color: colorScheme.error, width: 2.5), // 2.5px Red
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Labels always above
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface, // Pure white
        elevation: 0, // Semantic separation, not decoration
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 16px radius
          side: BorderSide(color: colorScheme.surfaceContainerHighest, width: 1.5), // Low-contrast outlines
        ),
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.stackSm),
      ),
      extensions: [
        AccessibilityThemeExtension(
          quizCorrectColor: colorScheme.brightness == Brightness.dark ? const Color(0xFF81C784) : const Color(0xFF4CAF50), // Green 300 / 500
          quizIncorrectColor: colorScheme.brightness == Brightness.dark ? const Color(0xFFE57373) : const Color(0xFFF44336), // Red 300 / 500
          focusRingColor: const Color(0xFFFFD54F), // Focus Gold
          touchTargetMargin: settings.touchTargetMargin,
        ),
      ],
    );
  }
}

class AccessibilityThemeExtension extends ThemeExtension<AccessibilityThemeExtension> {
  final Color quizCorrectColor;
  final Color quizIncorrectColor;
  final Color focusRingColor;
  final double touchTargetMargin;

  const AccessibilityThemeExtension({
    required this.quizCorrectColor,
    required this.quizIncorrectColor,
    required this.focusRingColor,
    required this.touchTargetMargin,
  });

  @override
  AccessibilityThemeExtension copyWith({
    Color? quizCorrectColor,
    Color? quizIncorrectColor,
    Color? focusRingColor,
    double? touchTargetMargin,
  }) {
    return AccessibilityThemeExtension(
      quizCorrectColor: quizCorrectColor ?? this.quizCorrectColor,
      quizIncorrectColor: quizIncorrectColor ?? this.quizIncorrectColor,
      focusRingColor: focusRingColor ?? this.focusRingColor,
      touchTargetMargin: touchTargetMargin ?? this.touchTargetMargin,
    );
  }

  @override
  AccessibilityThemeExtension lerp(ThemeExtension<AccessibilityThemeExtension>? other, double t) {
    if (other is! AccessibilityThemeExtension) {
      return this;
    }
    return AccessibilityThemeExtension(
      quizCorrectColor: Color.lerp(quizCorrectColor, other.quizCorrectColor, t)!,
      quizIncorrectColor: Color.lerp(quizIncorrectColor, other.quizIncorrectColor, t)!,
      focusRingColor: Color.lerp(focusRingColor, other.focusRingColor, t)!,
      touchTargetMargin: touchTargetMargin + (other.touchTargetMargin - touchTargetMargin) * t,
    );
  }
}
