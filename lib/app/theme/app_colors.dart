import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const primary = Color(0xFF4285F4);
  static const primaryDark = Color(0xFF316CE4);
  static const primaryLight = Color(0xFF4885FF);

  // Surface and background
  static const lightGray = Color(0xFFF5F5F5);
  static const mediumGray = Color(0xFF757575);
  static const darkGray = Color(0xFF212121);

  // Dark theme surfaces
  static const darkSurface = Color(0xFF121212);
  static const darkSurfaceVariant = Color(0xFF1E1E1E);
  static const darkOnSurfaceVariant = Color(0xFFB0B0B0);

  // Avatar colors for family members
  static const avatarColors = [
    Color(0xFFFFF59D), // Light yellow
    Color(0xFFFFCC80), // Light orange
    Color(0xFFFFAB91), // Light coral
    Color(0xFF81D4FA), // Light blue
    Color(0xFFB39DDB), // Light purple
    Color(0xFFFCE4EC), // Light pink
  ];

  // Health zone colors
  static const zoneCriticalLow = Color(0xFFB71C1C);
  static const zoneWarning = Color(0xFFF57C00);
  static const zoneNormal = Color(0xFF2E7D32);
  static const zoneCriticalHigh = Color(0xFFB71C1C);

  // Paywall theme
  static const paywallPurple = Color(0xFF7C4DFF);
  static const paywallPink = Color(0xFFFF6B9D);
  static const paywallYellow = Color(0xFFFFD54F);

  // Sync status
  static const syncPending = Color(0xFFFFA726);
  static const syncFailed = Color(0xFFEF5350);
  static const syncSuccess = Color(0xFF66BB6A);

  /// Get avatar color by index (cycles through palette).
  static Color getAvatarColor(int index) =>
      avatarColors[index % avatarColors.length];

  // Light color scheme
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryLight,
    onPrimaryContainer: Colors.white,
    secondary: primaryDark,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD6E3FF),
    onSecondaryContainer: Color(0xFF001B3E),
    surface: Colors.white,
    onSurface: darkGray,
    surfaceContainerHighest: lightGray,
    onSurfaceVariant: mediumGray,
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    outline: mediumGray,
    inverseSurface: Colors.black,
    onInverseSurface: Colors.white,
  );

  // Dark color scheme
  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: Colors.black,
    primaryContainer: primaryDark,
    onPrimaryContainer: Colors.white,
    secondary: primary,
    onSecondary: Colors.black,
    secondaryContainer: Color(0xFF004494),
    onSecondaryContainer: Color(0xFFD6E3FF),
    surface: darkSurface,
    onSurface: Colors.white,
    surfaceContainerHighest: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    outline: Color(0xFF757575),
    inverseSurface: Colors.white,
    onInverseSurface: Colors.black,
  );
}
