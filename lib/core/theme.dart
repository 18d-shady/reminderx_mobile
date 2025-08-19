import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF8EB0D6);
  static const secondary = Color.fromRGBO(142, 176, 214, 0.5); // #8EB0D6 @ 50%
  static const lightBackground = Colors.white;
  static const darkBackground = Color(0xFF121212);
  static const lightText = Colors.black87;
  static const darkText = Colors.white70;
  
  // Dark theme specific colors
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkCard = Color(0xFF2C2C2C);
  static const darkDivider = Color(0xFF3C3C3C);
  static const darkError = Color(0xFFCF6679);
  static const darkSuccess = Color(0xFF81C784);

  // Light theme specific colors
  static const lightDivider = Color(0xFFE0E0E0);
  static const lightCard = Colors.white; // Changed back to white
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      background: AppColors.lightBackground,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
      onBackground: AppColors.lightText,
      onError: Colors.white,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightCard,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'InknutAntiqua',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'InriaSans',
        fontSize: 14,
        color: AppColors.lightText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.darkError,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    cardColor: AppColors.darkCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'InknutAntiqua',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'InriaSans',
        fontSize: 14,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'InriaSans',
        fontSize: 13,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: 'InriaSans',
        fontSize: 12,
        color: AppColors.darkText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.primary,
    ),
  );

  static Color getExpiryColor(bool isExpiringSoon, bool isDark) {
    if (isExpiringSoon) {
      return isDark ? AppColors.darkError : Colors.red;
    }
    return isDark ? AppColors.darkSuccess : Colors.green;
  }

  static Color getBackgroundColor(bool isDark) {
    return isDark ? AppColors.darkSurface : Colors.white;
  }

  static Color getSurfaceColor(bool isDark) {
    return isDark ? AppColors.darkCard : Colors.grey[100]!;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? Colors.white : AppColors.lightText;
  }

  static Color getSecondaryTextColor(bool isDark) {
    return isDark ? AppColors.darkText : Colors.grey[600]!;
  }
}
