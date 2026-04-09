import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
<<<<<<< HEAD
  // ─── Light Soothing Color Palette ─────────────────
  static const Color primary = Color(0xFF7C6AEF);       // Soft indigo-lavender
  static const Color primaryDark = Color(0xFF6355D0);    // Deeper lavender
  static const Color accent = Color(0xFF4ECDC4);         // Calm teal
  static const Color background = Color(0xFFF5F7FA);     // Soft off-white
  static const Color surface = Color(0xFFFFFFFF);        // Clean white
  static const Color surfaceLight = Color(0xFFEEF0F7);   // Gentle lavender-gray
  static const Color cardColor = Color(0xFFFFFFFF);      // White cards
  static const Color textPrimary = Color(0xFF2D3142);    // Deep navy-gray
  static const Color textSecondary = Color(0xFF9098B1);  // Soft blue-gray
  static const Color success = Color(0xFF34C759);        // Apple-style green
  static const Color warning = Color(0xFFFFB347);        // Soft orange
  static const Color error = Color(0xFFFF6B6B);          // Soft red-coral
  static const Color highPriority = Color(0xFFFF6B6B);
  static const Color mediumPriority = Color(0xFFFFB347);
  static const Color lowPriority = Color(0xFF34C759);

  // ─── Gradients ─────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C6AEF), Color(0xFF4ECDC4)],
=======
  // ─── Color Palette ─────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color accent = Color(0xFF00D9FF);
  static const Color background = Color(0xFF0F0F23);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color cardColor = Color(0xFF16213E);
  static const Color textPrimary = Color(0xFFF1F1F1);
  static const Color textSecondary = Color(0xFF8D8DAA);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB40);
  static const Color error = Color(0xFFFF5252);
  static const Color highPriority = Color(0xFFFF5252);
  static const Color mediumPriority = Color(0xFFFFAB40);
  static const Color lowPriority = Color(0xFF00E676);

  // ─── Gradients ─────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D9FF)],
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
<<<<<<< HEAD
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F2F8)],
=======
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
<<<<<<< HEAD
    colors: [Color(0xFFEDE7F6), Color(0xFFE8F5E9), Color(0xFFE0F7FA)],
=======
    colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E), Color(0xFF16213E)],
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Theme Data ────────────────────────────────────
<<<<<<< HEAD
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
=======
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
<<<<<<< HEAD
        elevation: 2,
        shadowColor: const Color(0xFF7C6AEF).withValues(alpha: 0.08),
=======
        elevation: 0,
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
<<<<<<< HEAD
          borderSide: BorderSide(color: const Color(0xFF9098B1).withValues(alpha: 0.2)),
=======
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
    );
  }

  // ─── Helper Methods ────────────────────────────────
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return highPriority;
      case 'medium':
        return mediumPriority;
      case 'low':
        return lowPriority;
      default:
        return mediumPriority;
    }
  }

  static IconData getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'low':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  static BoxDecoration get glassDecoration => BoxDecoration(
<<<<<<< HEAD
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFFE8ECF4)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7C6AEF).withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
=======
    color: Colors.white.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
>>>>>>> 1857e7b4704833ecb56ea7aa8f02cf3891f2dbd0
  );
}
