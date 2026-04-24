import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.lightBackground,

    colorScheme: const ColorScheme.light(
      primary: AppColors.blue500,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: AppColors.lightCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    dividerColor: AppColors.lightBorder,

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBg,

      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(14),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.blue500,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightTextSecondary,
      ),
    ),
  );


  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue500,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.neutral800,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    dividerColor: AppColors.darkBorder,

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBg,

      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.darkBorder,
        ),
        borderRadius: BorderRadius.circular(14),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.blue500,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkTextSecondary,
      ),
    ),
  );
}