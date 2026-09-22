// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightBackground.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightBackground, width: 1),
      ),
      titleTextStyle: const TextStyle(color: AppColors.textLightMode, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: AppColors.textLightMode,),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textLightMode),
      bodyLarge: TextStyle(color: AppColors.textLightMode, fontWeight: FontWeight.bold),
    ),
    hintColor: AppColors.textMuted,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.textDarkMode,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textLightMode
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightBackground,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryBlue,
      selectionColor: AppColors.primaryBlue.withOpacity(0.3),
      selectionHandleColor: AppColors.primaryBlue.withOpacity(0.3),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.textMuted),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
      ),
    ),
  );


  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkBackground.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.darkBackground, width: 1),
      ),
      titleTextStyle: const TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: AppColors.textDarkMode,),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textDarkMode),
      bodyLarge: TextStyle(color: AppColors.textDarkMode, fontWeight: FontWeight.bold),
    ),
    hintColor: AppColors.textMuted,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.textDarkMode,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textDarkMode
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkBackground,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryBlue,
      selectionColor: AppColors.primaryBlue.withOpacity(0.3),
      selectionHandleColor: AppColors.primaryBlue.withOpacity(0.3),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.textMuted),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
      ),
    ),
  );
}