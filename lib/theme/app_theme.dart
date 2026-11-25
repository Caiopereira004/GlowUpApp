import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  final Color bg;
  final Color surface;
  final Color surfaceSoft;
  final Color tint;
  final Color primary;
  final Color primaryDeep;
  final Color primarySoft;
  final Color sage;
  final Color sageSoft;
  final Color champagne;
  final Color text;
  final Color textSub;
  final Color border;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceSoft,
    required this.tint,
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.sage,
    required this.sageSoft,
    required this.champagne,
    required this.text,
    required this.textSub,
    required this.border,
  });

  static const light = AppColors(
    bg: Color(0xFFFAF8F6),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFF3ECE8),
    tint: Color(0xFFF9E6EC),
    primary: Color(0xFF9E4761),
    primaryDeep: Color(0xFF7A3248),
    primarySoft: Color(0xFFF9E6EC),
    sage: Color(0xFF4D7C68),
    sageSoft: Color(0xFFEBF3EF),
    champagne: Color(0xFFD4A373),
    text: Color(0xFF1E191B),
    textSub: Color(0xFF665B5E),
    border: Color(0xFFEAE0DA),
  );

  static const dark = AppColors(
    bg: Color(0xFF121113),
    surface: Color(0xFF1C1A1E),
    surfaceSoft: Color(0xFF252229),
    tint: Color(0xFF2B1E24),
    primary: Color(0xFFDF829C),
    primaryDeep: Color(0xFFF3B3C4),
    primarySoft: Color(0xFF332129),
    sage: Color(0xFF6FA88E),
    sageSoft: Color(0xFF1E2E27),
    champagne: Color(0xFFE2B887),
    text: Color(0xFFF6F2F4),
    textSub: Color(0xFFABA1A5),
    border: Color(0xFF2F2B34),
  );

  static const highContrast = AppColors(
    bg: Color(0xFF000000),
    surface: Color(0xFF0D0D0D),
    surfaceSoft: Color(0xFF1A1A1A),
    tint: Color(0xFF241018),
    primary: Color(0xFFFF8FB1),
    primaryDeep: Color(0xFFFFC4D6),
    primarySoft: Color(0xFF3A1624),
    sage: Color(0xFF7AE5B5),
    sageSoft: Color(0xFF112B20),
    champagne: Color(0xFFFFD166),
    text: Color(0xFFFFFFFF),
    textSub: Color(0xFFE5E5E5),
    border: Color(0xFFFFFFFF),
  );

  static AppColors of({required bool darkMode, required bool highContrastMode}) {
    if (highContrastMode) return highContrast;
    if (darkMode) return dark;
    return light;
  }
}

class AppTheme {
  static ThemeData buildTheme({
    required bool darkMode,
    required bool highContrast,
  }) {
    final c = AppColors.of(darkMode: darkMode, highContrastMode: highContrast);
    final isDark = darkMode || highContrast;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: c.bg,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: c.primary,
        onPrimary: Colors.white,
        secondary: c.sage,
        onSecondary: Colors.white,
        error: const Color(0xFFE11D48),
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.text,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: c.text,
        displayColor: c.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: c.border,
    );
  }
}
