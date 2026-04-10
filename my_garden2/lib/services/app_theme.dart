import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color cream = Color(0xFFFAF7F0);
  static const Color sage = Color(0xFF7BA05B);
  static const Color deepGreen = Color(0xFF3D6B35);
  static const Color terracotta = Color(0xFFD4785A);
  static const Color gold = Color(0xFFE8C547);
  static const Color lavender = Color(0xFFB8A9C9);
  static const Color blush = Color(0xFFE8B4B8);
  static const Color sky = Color(0xFF87CEEB);
  static const Color bark = Color(0xFF8B6914);
  static const Color parchment = Color(0xFFF5EDD8);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: sage,
          brightness: Brightness.light,
          background: cream,
          surface: parchment,
          primary: deepGreen,
          secondary: terracotta,
        ),
        scaffoldBackgroundColor: cream,
        textTheme: GoogleFonts.limelightTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 36, fontWeight: FontWeight.w700, color: deepGreen,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 28, fontWeight: FontWeight.w600, color: deepGreen,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            fontSize: 22, fontWeight: FontWeight.w600, color: deepGreen,
          ),
          bodyLarge: GoogleFonts.lato(fontSize: 16, color: const Color(0xFF3A3028)),
          bodyMedium: GoogleFonts.lato(fontSize: 14, color: const Color(0xFF5A4A3A)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
            fontSize: 24, fontWeight: FontWeight.w700, color: deepGreen,
          ),
          iconTheme: const IconThemeData(color: deepGreen),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: deepGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sage.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: sage.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: deepGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
