import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme(String fontFamily) {
    TextStyle baseStyle;
    
    switch (fontFamily) {
      case 'OpenDyslexic':
        baseStyle = const TextStyle(fontFamily: 'OpenDyslexic');
        break;
      case 'Roboto':
        baseStyle = GoogleFonts.roboto();
        break;
      case 'Lexend':
        baseStyle = GoogleFonts.lexend();
        break;
      case 'Atkinson Hyperlegible':
      default:
        baseStyle = GoogleFonts.atkinsonHyperlegible();
        break;
    }
    
    return TextTheme(
      displayLarge: baseStyle.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700, // Bold
        height: 42 / 34,
        letterSpacing: -0.01 * 34,
      ),
      headlineLarge: baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        letterSpacing: 0,
      ),
      headlineMedium: baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600, // Medium/SemiBold
        height: 30 / 22,
        letterSpacing: 0.01 * 22,
      ),
      bodyLarge: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        letterSpacing: 0.02 * 18,
      ),
      bodyMedium: baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0.02 * 16,
      ),
      labelLarge: baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        letterSpacing: 0.05 * 14,
      ),
      // Used for button typography
      labelMedium: baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 24 / 18,
        letterSpacing: 0.03 * 18,
      ),
    );
  }
}
