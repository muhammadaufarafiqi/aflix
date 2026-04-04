import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary       = Color(0xFFE50914);
  static const Color background    = Color(0xFF141414);
  static const Color surface       = Color(0xFF1A1A1A);
  static const Color card          = Color(0xFF2A2A2A);
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFF8A8A8A);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary, secondary: primary,
      background: background, surface: surface,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}
