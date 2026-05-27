import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // =========================
  // LIGHT THEME COLORS
  // =========================
  static const Color primaryAccent = Color(0xFF2D5A27);
  static const Color primaryHover = Color(0xFF1E3F1A);
  static const Color background = Color(0xFFFDF5E6);
  static const Color surface = Colors.white;
  static const Color terracotta = Color(0xFFA0522D);
  static const Color textPrimary = Color(0xFF1B1F1B);

  static final Color textMuted =
      const Color(0xFF2D5A27).withOpacity(0.60);

  static const Color inputBorder = Color(0xFFD4CDC3);

  // =========================
  // DARK THEME COLORS
  // =========================
  static const Color darkBackground = Color(0xFF081408);
  static const Color darkSurface = Color(0xFF122312);
  static const Color darkTextPrimary = Colors.white;

  static final Color darkTextMuted =
      Colors.white.withOpacity(0.70);

  static const Color darkInputBorder = Color(0xFF1B301B);
  static const Color darkPrimaryAccent = Color(0xFF81C784);
  static const Color creamSurface = Color(0xFFF7F2E8);

  // =========================
  // LIGHT THEME
  // =========================
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        primary: primaryAccent,
        secondary: terracotta,
        surface: surface,
      ),

      scaffoldBackgroundColor: background,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF1B1F1B),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFF1B1F1B),
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
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
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: inputBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryAccent,
            width: 2,
          ),
        ),
      ),

      // FIXED
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(
            color: terracotta.withOpacity(0.1),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(
            double.infinity,
            64,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryAccent,
        unselectedItemColor:
            primaryAccent.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // =========================
  // DARK THEME
  // =========================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: darkPrimaryAccent,
        secondary: darkPrimaryAccent,
        surface: darkSurface,
        onSurface: darkTextPrimary,
      ),

      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkSurface,
      dialogBackgroundColor: darkSurface,

      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      iconTheme: const IconThemeData(
        color: Colors.white,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: darkTextPrimary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: darkInputBorder,
            width: 1.5,
          ),
        ),
      ),

      // FIXED
      cardTheme: CardThemeData(
        color: creamSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: creamSurface,
          foregroundColor: Colors.black,
          minimumSize: const Size(
            double.infinity,
            64,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),

      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor:
            darkPrimaryAccent,
        unselectedItemColor:
            Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}