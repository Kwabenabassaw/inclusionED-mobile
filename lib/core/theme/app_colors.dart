import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors (from Cognitive Clarity Design System)
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceDim = Color(0xFFDBD9E1);
  static const Color surfaceBright = Color(0xFFFBF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FA);
  static const Color surfaceContainer = Color(0xFFEFEDF5);
  static const Color surfaceContainerHigh = Color(0xFFE9E7EF);
  static const Color surfaceContainerHighest = Color(0xFFE3E1E9);
  
  static const Color onSurface = Color(0xFF1B1B21);
  static const Color onSurfaceVariant = Color(0xFF454651);
  static const Color inverseSurface = Color(0xFF303036);
  static const Color inverseOnSurface = Color(0xFFF2EFF7);
  
  static const Color outline = Color(0xFF767683);
  static const Color outlineVariant = Color(0xFFC6C5D3);
  static const Color surfaceTint = Color(0xFF4858AB);
  
  static const Color primary = Color(0xFF4352A5); // Primary: #4352a5
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF5C6BC0);
  static const Color onPrimaryContainer = Color(0xFFF8F6FF);
  static const Color inversePrimary = Color(0xFFBAC3FF);
  
  static const Color secondary = Color(0xFF4F6073);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD2E4FB);
  static const Color onSecondaryContainer = Color(0xFF556679);
  
  static const Color tertiary = Color(0xFF595956);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF71716E);
  static const Color onTertiaryContainer = Color(0xFFF9F7F3);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const Color background = Color(0xFFFBF8FF);
  static const Color onBackground = Color(0xFF1B1B21);
  static const Color surfaceVariant = Color(0xFFE3E1E9);

  // Focus Gold (from Brand & Style text)
  static const Color focusGold = Color(0xFFFFD54F);
}

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onTertiary,
  tertiaryContainer: AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.onTertiaryContainer,
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  surfaceContainerHighest: AppColors.surfaceVariant,
  onSurfaceVariant: AppColors.onSurfaceVariant,
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,
  inverseSurface: AppColors.inverseSurface,
  onInverseSurface: AppColors.inverseOnSurface,
  inversePrimary: AppColors.inversePrimary,
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFBAC3FF),
  onPrimary: Color(0xFF0F2275),
  primaryContainer: Color(0xFF29398C),
  onPrimaryContainer: Color(0xFFDEE0FF),
  secondary: Color(0xFFB5C8E1),
  onSecondary: Color(0xFF203243),
  secondaryContainer: Color(0xFF37485A),
  onSecondaryContainer: Color(0xFFD2E4FB),
  tertiary: Color(0xFFC7C7C3),
  onTertiary: Color(0xFF2B2B2A),
  tertiaryContainer: Color(0xFF424240),
  onTertiaryContainer: Color(0xFFE3E3DE),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF131316),
  onSurface: Color(0xFFE4E2E8),
  surfaceContainerHighest: Color(0xFF35343A),
  onSurfaceVariant: Color(0xFFC7C5CE),
  outline: Color(0xFF918F9A),
  outlineVariant: Color(0xFF46464F),
  inverseSurface: Color(0xFFE4E2E8),
  onInverseSurface: Color(0xFF303036),
  inversePrimary: AppColors.primary,
);

const ColorScheme highContrastLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF00115F),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF223286),
  onPrimaryContainer: Color(0xFFFFFFFF),
  secondary: Color(0xFF142738),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF334456),
  onSecondaryContainer: Color(0xFFFFFFFF),
  tertiary: Color(0xFF1E1E1D),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF3E3E3C),
  onTertiaryContainer: Color(0xFFFFFFFF),
  error: Color(0xFF4E0002),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF8C0009),
  onErrorContainer: Color(0xFFFFFFFF),
  surface: Color(0xFFFBF8FF),
  onSurface: Color(0xFF000000),
  surfaceContainerHighest: Color(0xFFE3E1E9),
  onSurfaceVariant: Color(0xFF23242E),
  outline: Color(0xFF41414D),
  outlineVariant: Color(0xFF41414D),
  inverseSurface: Color(0xFF303036),
  onInverseSurface: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFFE6E8FF),
);

const ColorScheme highContrastDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFAFAFF),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFFBECAF7),
  onPrimaryContainer: Color(0xFF000000),
  secondary: Color(0xFFFAFAFF),
  onSecondary: Color(0xFF000000),
  secondaryContainer: Color(0xFFBDD0E9),
  onSecondaryContainer: Color(0xFF000000),
  tertiary: Color(0xFFFAFAFF),
  onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFFC7C7C3),
  onTertiaryContainer: Color(0xFF000000),
  error: Color(0xFFFFF9F9),
  onError: Color(0xFF000000),
  errorContainer: Color(0xFFFFBAB1),
  onErrorContainer: Color(0xFF000000),
  surface: Color(0xFF131316),
  onSurface: Color(0xFFFFFFFF),
  surfaceContainerHighest: Color(0xFF35343A),
  onSurfaceVariant: Color(0xFFFAFAFF),
  outline: Color(0xFFE4E2E8),
  outlineVariant: Color(0xFFE4E2E8),
  inverseSurface: Color(0xFFE4E2E8),
  onInverseSurface: Color(0xFF000000),
  inversePrimary: Color(0xFF273686),
);
