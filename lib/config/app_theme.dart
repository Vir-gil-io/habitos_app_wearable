import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary   = Color(0xFF6C5CE7);
  static const Color completed = Color(0xFF00B894);
  static const Color pending   = Color(0xFFE17055);
  static const Color streak    = Color(0xFFFF7675);

  static const Color background = Color(0xFF000000);
  static const Color surface    = Color(0xFF1A1A2E);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color divider       = Color(0xFF2D2D44);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: completed,
          surface: surface,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary,
          ),
          bodyMedium: TextStyle(fontSize: 12, color: textSecondary),
          labelSmall: TextStyle(fontSize: 10, color: textSecondary),
        ),
      );
}