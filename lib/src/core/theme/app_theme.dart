import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Meticulously curated palette - Burgundy & Warm Gold
  static const Color primaryLight = Color(0xFF8B001B); // Burgundy
  static const Color goldLight = Color(0xFFD4AF37);    // Warm Gold

  // Serene Backgrounds
  static const Color bgLight = Color(0xFFFAF8F5);      // Warm Cream Background (Restored)
  static const Color surfaceLight = Color(0xFFFFFFFF); // White Surface
  
  static const Color textPrimaryLight = Color(0xFF3B1E1E); // Deep Brown Text
  static const Color textSecondaryLight = Color(0xFF7D5852); // Medium Brown Text

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: goldLight,
        surface: surfaceLight,
        error: Color(0xFFBA1A1A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
      ),
      scaffoldBackgroundColor: bgLight,
      dividerColor: textSecondaryLight.withValues(alpha: 0.1),
      
      // Card Themes - 24.0 border radius for soft, rounded look
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: textSecondaryLight.withValues(alpha: 0.08), width: 1),
        ),
      ),

      // Input Decoration Theme - Ultra rounded search bars
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        labelStyle: GoogleFonts.cairo(color: textSecondaryLight, fontSize: 13),
        hintStyle: GoogleFonts.cairo(color: textSecondaryLight.withValues(alpha: 0.6), fontSize: 13),
      ),

      // Buttons Theme - Rounded pill shapes (stadium border)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 0,
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryLight),
      ),

      // Text Theme - Unified Cairo/Amiri layout
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(color: textPrimaryLight, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.cairo(color: textPrimaryLight, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.cairo(color: textPrimaryLight, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.cairo(color: textPrimaryLight, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.cairo(color: textPrimaryLight, fontWeight: FontWeight.bold, fontSize: 18),
        titleMedium: GoogleFonts.cairo(color: textPrimaryLight, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.cairo(color: textPrimaryLight, fontSize: 15),
        bodyMedium: GoogleFonts.cairo(color: textSecondaryLight, fontSize: 13),
        labelLarge: GoogleFonts.cairo(color: primaryLight, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
