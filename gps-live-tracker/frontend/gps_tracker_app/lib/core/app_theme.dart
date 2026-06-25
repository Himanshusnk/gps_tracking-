import 'package:flutter/material.dart';

class AppTheme {
  // Ultra-modern custom palette
  static const Color primaryBgDark = Color(0xFF0F172A); // slate-900
  static const Color cardBgDark = Color(0xFF1E293B);    // slate-800
  static const Color primaryAccent = Color(0xFF6366F1);  // indigo-500
  static const Color secondaryAccent = Color(0xFF06B6D4); // cyan-500
  static const Color errorColor = Color(0xFFEF4444);      // red-500
  static const Color successColor = Color(0xFF10B981);    // emerald-500
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // slate-50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // slate-400

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBgDark,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: secondaryAccent,
        surface: primaryBgDark,
        error: errorColor,
      ),
      cardTheme: CardThemeData(
        color: cardBgDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1), // slate-700
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(color: textPrimaryDark),
        bodyMedium: TextStyle(color: textSecondaryDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBgDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
