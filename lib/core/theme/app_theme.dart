import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Application theme configuration
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: AppColors.primaryBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepFern.withValues(alpha: 0.95),
        elevation: AppSizes.appBarElevation,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepFern,
        secondary: AppColors.tropicalLime,
        surface: AppColors.primaryBackground,
        onSurface: AppColors.primaryText,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: AppSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepFern.withValues(alpha: 0.95),
        elevation: AppSizes.appBarElevation,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepFern,
        brightness: Brightness.dark,
        secondary: AppColors.tropicalLime,
        surface: AppColors.darkCardBackground,
        onSurface: AppColors.lightText,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCardBackground,
        elevation: AppSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
      ),
    );
  }
}
