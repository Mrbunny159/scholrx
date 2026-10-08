import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlue, // 🟢 FIXED: Ab naya Primary Blue use hoga
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue, // 🟢 FIXED
        secondary: AppColors.warningOrange,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.divider,
      ),
      
      // 📝 Clean Hierarchy Typography (Apple/SaaS Style)
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        bodyLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        labelLarge: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),

      // 🖼️ Card Protocol (Clean Surface)
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // 🔘 Premium SaaS-style Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // No shadow for modern flat look
          backgroundColor: AppColors.primaryBlue, // 🟢 FIXED
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // 📱 Transparent AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0, 
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        centerTitle: false,
      ),
    );
  }
}