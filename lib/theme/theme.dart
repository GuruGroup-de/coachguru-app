import 'package:flutter/material.dart';

/// CoachGuru Theme Colors
class CoachGuruTheme {
  // Main brand colors
  static const Color mainBlue = Color(0xFF4A90E2);
  static const Color lightBlue = Color(0xFFD7EBFF);
  static const Color accentGreen = Color(0xFF4CAF50);

  // Neutral colors
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF7A7A7A);

  // Additional utility colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);

  // Private constructor to prevent instantiation
  CoachGuruTheme._();
}

/// CoachGuru Material 3 Theme
final ThemeData coachGuruTheme = ThemeData(
  useMaterial3: true,

  // Color Scheme (Material 3)
  colorScheme: ColorScheme.fromSeed(
    seedColor: CoachGuruTheme.mainBlue,
    brightness: Brightness.light,
    primary: CoachGuruTheme.mainBlue,
    secondary: CoachGuruTheme.accentGreen,
    surface: CoachGuruTheme.softGrey,
    background: CoachGuruTheme.softGrey,
    error: CoachGuruTheme.errorRed,
  ),

  // Primary color
  primaryColor: CoachGuruTheme.mainBlue,

  // Scaffold background
  scaffoldBackgroundColor: CoachGuruTheme.softGrey,

  // AppBar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: CoachGuruTheme.mainBlue,
    foregroundColor: CoachGuruTheme.white,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: const TextStyle(
      color: CoachGuruTheme.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    iconTheme: const IconThemeData(color: CoachGuruTheme.white, size: 24),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: CoachGuruTheme.mainBlue,
      foregroundColor: CoachGuruTheme.white,
      minimumSize: const Size(200, 52),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 2,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: CoachGuruTheme.mainBlue,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: CoachGuruTheme.mainBlue,
      side: const BorderSide(color: CoachGuruTheme.mainBlue, width: 2),
      minimumSize: const Size(200, 52),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.15),
    color: CoachGuruTheme.white,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Icon Theme
  iconTheme: const IconThemeData(color: CoachGuruTheme.mainBlue, size: 24),

  // Floating Action Button Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: CoachGuruTheme.mainBlue,
    foregroundColor: CoachGuruTheme.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: CoachGuruTheme.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: CoachGuruTheme.mainBlue.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: CoachGuruTheme.mainBlue.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: CoachGuruTheme.mainBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: CoachGuruTheme.errorRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: CoachGuruTheme.errorRed, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  // Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    bodySmall: TextStyle(
      color: CoachGuruTheme.textLight,
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    labelLarge: TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: CoachGuruTheme.textLight,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: CoachGuruTheme.textLight,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: CoachGuruTheme.white,
    selectedItemColor: CoachGuruTheme.mainBlue,
    unselectedItemColor: CoachGuruTheme.textLight,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
    ),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  // Divider Theme
  dividerTheme: DividerThemeData(
    color: CoachGuruTheme.mainBlue.withOpacity(0.1),
    thickness: 1,
    space: 1,
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: CoachGuruTheme.lightBlue,
    selectedColor: CoachGuruTheme.mainBlue,
    labelStyle: const TextStyle(color: CoachGuruTheme.textDark, fontSize: 14),
    secondaryLabelStyle: const TextStyle(
      color: CoachGuruTheme.white,
      fontSize: 14,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: CoachGuruTheme.white,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    titleTextStyle: const TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(
      color: CoachGuruTheme.textDark,
      fontSize: 16,
    ),
  ),

  // Bottom Sheet Theme
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: CoachGuruTheme.white,
    elevation: 8,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
);
