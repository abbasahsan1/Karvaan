import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper class to manage fonts in the app
/// Uses Google Fonts package for dynamic font loading
class AppFonts {
  // Default text theme using Poppins from Google Fonts
  static TextTheme getTextTheme() {
    return GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: const Color(0xFF212121),
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        color: const Color(0xFF212121),
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: const Color(0xFF212121),
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: const Color(0xFF212121),
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: const Color(0xFF212121),
      ),
      titleSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: const Color(0xFF212121),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: const Color(0xFF757575),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF757575),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: const Color(0xFF757575),
      ),
    );
  }

  // Get a specific text style
  static TextStyle getTextStyle(String styleName) {
    final textTheme = getTextTheme();
    
    switch (styleName) {
      case 'headline1': return textTheme.headlineLarge!;
      case 'headline2': return textTheme.headlineMedium!;
      case 'headline3': return textTheme.headlineSmall!;
      case 'title1': return textTheme.titleLarge!;
      case 'title2': return textTheme.titleMedium!;
      case 'title3': return textTheme.titleSmall!;
      case 'body1': return textTheme.bodyLarge!;
      case 'body2': return textTheme.bodyMedium!;
      case 'body3': return textTheme.bodySmall!;
      default: return textTheme.bodyMedium!;
    }
  }
}
