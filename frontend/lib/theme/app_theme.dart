import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1A6B4A); // Deep Green (Growth)
  static const primaryLight = Color(0xFFD4E9E2); // Soft Green for highlights
  static const secondary = Color(0xFFF5A623); // Alert/Action
  static const accent = Color(0xFF2EC4B6);
  static const danger = Color(0xFFE63946);
  static const background = Color(0xFFF8FAFB); // Slightly cooler background
  static const card = Colors.white;
  static const dark = Color(0xFF1A1A2E);
  static const grey = Color(0xFF64748B); // Slate-grey for readability
  static const lightGrey = Color(0xFFE2E8F0);
  static const purple =
      Color(0xFF6B46C1); // For future use in charts or highlights
  static const orange = Color(0xFFF5A623); // For warnings or important actions
  static const blue = Color(0xFF3B82F6); // For informational highlights
  static const yellow = Color(0xFFFBBF24); // For positive highlights or tips
  static const pink = Color(0xFFEC4899); // For special features or promotions
  static const teal =
      Color(0xFF14B8A6); // For success messages or confirmations
  static const indigo = Color(0xFF4F46E5); // For premium features or insights
  static const cyan = Color(0xFF06B6D4); // For interactive elements or links
  static const lime =
      Color(0xFF84CC16); // For growth indicators or positive trends
  static const amber = Color(0xFFFFC107); // For highlights or important notices
  static const brown =
      Color(0xFF795548); // For earthy tones or financial stability themes
  static const greyDark =
      Color(0xFF374151); // For secondary text or less prominent elements
  static const greyLight =
      Color(0xFF9CA3AF); // For disabled states or placeholders
  static const greyLighter = Color(0xFFF3F4F6); // For backgrounds or dividers
  static const greyDarkest =
      Color(0xFF111827); // For primary text or dark mode themes
  static const greyLightest =
      Color(0xFFFAFAFA); // For highlights or very light backgrounds
  static const greyMid =
      Color(0xFF6B7280); // For neutral elements or secondary actions
  static const greyMuted =
      Color(0xFF4B5563); // For muted text or less important information
  static const greyMutedLight =
      Color(0xFF9CA3AF); // For lighter muted text or placeholders
  static const greyMutedDark =
      Color(0xFF374151); // For darker muted text or secondary information
  static const greyMutedLighter =
      Color(0xFFF3F4F6); // For very light muted backgrounds or dividers
  static const amberText =
      Color(0xFFFFC107); // For text highlights or important notices
  static const subtleOrange =
      Color(0xFFFFF7ED); // For subtle warnings or highlights
}

class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.card,
        background: AppColors.background,
        error: AppColors.danger,
      ),

      // Global Text Styling
      textTheme: baseTextTheme.copyWith(
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.grey,
        ),
      ),

      // 💳 Refined Card Theme
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24), // Softer corners for youth appeal
          side: BorderSide(color: AppColors.lightGrey, width: 1),
        ),
      ),

      // ⌨️ AI Input Field Theme (For the Spending Analyzer)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      // 🔘 Modern Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),

      // 🎚️ Simulator Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryLight,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.1),
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
