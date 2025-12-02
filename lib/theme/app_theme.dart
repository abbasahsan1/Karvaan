import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand palette – vibrant neon-to-indigo blend for a glassmorphism aesthetic
  static const Color primaryColor = Color(0xFF22D3EE);
  static const Color primaryColorDark = Color(0xFF0E7490);
  static const Color primaryColorLight = Color(0xFF67E8F9);

  static const Color accentColor = Color(0xFF38BDF8);
  static const Color accentColorDark = Color(0xFF2563EB);
  static const Color accentColorLight = Color(0xFF93C5FD);
  static const Color accentBlueColor = Color(0xFF60A5FA);
  static const Color accentRedColor = Color(0xFFF87171);

  // Text colors for light/dark contrasts
  static const Color textPrimaryColor = Color(0xFFE2E8F0);
  static const Color textSecondaryColor = Color(0xFF94A3B8);
  static const Color textDarkColor = Color(0xFFF8FAFC);
  static const Color textDarkSecondaryColor = Color(0xFFCBD5F5);

  // Surfaces & backdrop
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color backgroundDarkColor = Color(0xFF020617);
  static const Color surfaceColor = Color(0x3327388B);
  static const Color surfaceDarkColor = Color(0x337485F9);

  // Support colors
  static const Color errorColor = Color(0xFFF87171);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFFBBF24);
  static const Color infoColor = Color(0xFF38BDF8);

  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF312E81)],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22D3EE), Color(0xFF38BDF8), Color(0xFF6366F1)],
  );

  static const double glassBlurSigma = 18.0;
  static const double glassBorderOpacity = 0.35;

  // Light theme
  static final ThemeData lightTheme = _buildTheme(Brightness.light);

  // Dark theme
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: isDark ? backgroundDarkColor : backgroundColor,
      splashFactory: InkRipple.splashFactory,
      textTheme: GoogleFonts.outfitTextTheme(
        brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
    );

    final Color onPrimary = Colors.white;
    final Color onBackground = isDark ? textDarkColor : textPrimaryColor;
    final Color surface = isDark ? surfaceDarkColor : surfaceColor;

    return base.copyWith(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: onPrimary,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,


        surface: surface,
        onSurface: onBackground,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onBackground,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.light,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackground,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.white.withValues(alpha: 0.08),
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: glassBorderOpacity),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.disabled)
                ? Colors.white24
                : primaryColor,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: accentColor,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onBackground,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: isDark ? 0.05 : 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1.2),
        ),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white54,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white60,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 1,
      ),
      chipTheme: ChipThemeData.fromDefaults(
        secondaryColor: accentColor,
        brightness: brightness,
        labelStyle: TextStyle(color: onBackground),
      ).copyWith(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
