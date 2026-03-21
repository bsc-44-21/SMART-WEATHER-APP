import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryAccent = Color(0xFF5A5A40); // Deep Olive
  static const Color primaryHover = Color(0xFF4A4A30); // Darker Olive
  static const Color background = Color(0xFFF5F5F0); // Warm Cream
  static const Color surface = Colors.white; // Pure White
  static const Color textPrimary = Color(0xFF1A1A1A); // Charcoal
  static final Color textMuted = const Color(0xFF5A5A40).withOpacity(0.60);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  // Dark Color Palette
  static const Color darkBackground = Color(0xFF1A1C19);
  static const Color darkSurface = Color(0xFF2D302C);
  static const Color darkTextPrimary = Color(0xFFE3E3E3);
  static final Color darkTextMuted = const Color(0xFFE3E3E3).withOpacity(0.60);
  static const Color darkInputBorder = Color(0xFF4A4C48);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        primary: primaryAccent,
        surface: surface,
        surfaceVariant: background,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      
      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 1.2,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          color: textMuted,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: inputBorder),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 1.2,
        ),
      ),