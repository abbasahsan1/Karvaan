import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF00A651); // Vibrant green
  static const Color backgroundColor = Color(0xFFF8F8F8); // Light gray
  static const Color textPrimaryColor = Color(0xFF333333); // Dark gray
  static const Color textSecondaryColor = Color(0xFF666666); // Medium gray
  static const Color accentBlueColor = Color(0xFF0066CC); // Blue accent
  static const Color accentRedColor = Color(0xFFE53935); // Red accent for alerts
  static const Color dividerColor = Color(0xFFE0E0E0); // Light gray for dividers
  
  // Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'SF Pro Display', // System font that resembles screenshots
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentBlueColor,
      error: accentRedColor,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimaryColor, fontSize: 28, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textPrimaryColor, fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimaryColor, fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textPrimaryColor, fontSize: 16),
      bodyMedium: TextStyle(color: textPrimaryColor, fontSize: 14),
      bodySmall: TextStyle(color: textSecondaryColor, fontSize: 12),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondaryColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
