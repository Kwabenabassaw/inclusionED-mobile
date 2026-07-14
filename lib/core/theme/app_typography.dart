import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

class AppTypography {
  static TextTheme getTextTheme(AccessibilitySettings settings) {
    TextStyle baseStyle;
    
    switch (settings.fontFamily) {
      case 'OpenDyslexic':
        baseStyle = const TextStyle(fontFamily: 'OpenDyslexic');
        break;
      case 'Roboto':
        baseStyle = GoogleFonts.roboto();
        break;
      case 'Lexend':
        baseStyle = GoogleFonts.lexend();
        break;
      case 'Georgia':
        baseStyle = GoogleFonts.lora(); // Use Lora as the highly legible Georgia alternative
        break;
      case 'System':
        baseStyle = const TextStyle(); // Default system font
        break;
      case 'Atkinson Hyperlegible':
      default:
        baseStyle = GoogleFonts.atkinsonHyperlegible();
        break;
    }
    
    final spacing = settings.lineSpacing;
    final isBold = settings.boldText;

    FontWeight getWeight(FontWeight defaultWeight) {
      if (!isBold) return defaultWeight;
      if (defaultWeight == FontWeight.w700 || defaultWeight == FontWeight.bold || defaultWeight == FontWeight.w800) return FontWeight.w900;
      if (defaultWeight == FontWeight.w600) return FontWeight.w800;
      return FontWeight.bold; // for w400, w500, etc.
    }
    
    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: 34,
        fontWeight: getWeight(FontWeight.w700),
        height: (42 / 34) * spacing,
        letterSpacing: -0.01 * 34,
      ),
      headlineLarge: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: getWeight(FontWeight.w700),
        height: (36 / 28) * spacing,
        letterSpacing: 0,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: 22,
        fontWeight: getWeight(FontWeight.w600),
        height: (30 / 22) * spacing,
        letterSpacing: 0.01 * 22,
      ),
      bodyLarge: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: getWeight(FontWeight.w400),
        height: (28 / 18) * spacing,
        letterSpacing: 0.02 * 18,
      ),
      bodyMedium: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: getWeight(FontWeight.w400),
        height: (24 / 16) * spacing,
        letterSpacing: 0.02 * 16,
      ),
      bodySmall: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: getWeight(FontWeight.w400),
        height: (20 / 14) * spacing,
        letterSpacing: 0.03 * 14,
      ),
      labelLarge: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: getWeight(FontWeight.w600),
        height: (20 / 14) * spacing,
        letterSpacing: 0.04 * 14,
      ),
      // Used for button typography
      labelMedium: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: getWeight(FontWeight.w700),
        height: (24 / 18) * spacing,
        letterSpacing: 0.03 * 18,
      ),
    );
  }
}
