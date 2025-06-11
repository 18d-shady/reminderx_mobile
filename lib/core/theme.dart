import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF8EB0D6);
  static const secondary = Color.fromRGBO(142, 176, 214, 0.5); // #8EB0D6 @ 50%
  static const lightBackground = Colors.white;
  static const darkBackground = Colors.black;
  static const lightText = Colors.black87;
  static const darkText = Colors.white70;
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'InknutAntiqua',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'InriaSans',
        fontSize: 16,
        color: AppColors.lightText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'InknutAntiqua',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'InriaSans',
        fontSize: 16,
        color: AppColors.darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
    ),
  );
}
