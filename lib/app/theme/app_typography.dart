import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Roboto';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 57,
          height: 64 / 57,
          letterSpacing: 0,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 45,
          height: 52 / 45,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 36,
          height: 44 / 36,
          letterSpacing: 0,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 32,
          height: 40 / 32,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 28,
          height: 36 / 28,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 24,
          height: 32 / 24,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 22,
          height: 28 / 22,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 24 / 18,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 24 / 16,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          height: 20 / 14,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          height: 16 / 12,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 11,
          height: 16 / 11,
          letterSpacing: 0.5,
        ),
      );
}
