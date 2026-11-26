import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Manrope type system for the Health Keeper redesign.
///
/// [textTheme] fills the standard Material slots (used by default widget
/// theming — buttons, app bars, dialogs). For everything screen-specific —
/// eyebrow labels, hero greetings, metric values — use the named styles
/// below instead; the design leans on sizes/weights that don't map cleanly
/// onto the 13 Material roles.
class AppTypography {
  AppTypography._();

  static TextStyle _m({
    required double size,
    required FontWeight weight,
    double? height,
    double letterSpacing = 0,
    Color? color,
    bool tabularFigures = false,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: tabularFigures ? const [FontFeature.tabularFigures()] : null,
    );
  }

  // ---------------------------------------------------------------------
  // Material TextTheme (generic widget defaults)
  // ---------------------------------------------------------------------

  static TextTheme get textTheme => TextTheme(
        displayLarge: _m(size: 46, weight: FontWeight.w800, height: 1, letterSpacing: -.045, tabularFigures: true),
        displayMedium: _m(size: 34, weight: FontWeight.w800, height: 1.15, letterSpacing: -.035),
        displaySmall: _m(size: 29, weight: FontWeight.w800, height: 1.2, letterSpacing: -.035),
        headlineLarge: _m(size: 26, weight: FontWeight.w800, height: 1.2, letterSpacing: -.035),
        headlineMedium: _m(size: 23, weight: FontWeight.w800, height: 1.25, letterSpacing: -.03),
        headlineSmall: _m(size: 21, weight: FontWeight.w800, height: 1.28, letterSpacing: -.03),
        titleLarge: _m(size: 18, weight: FontWeight.w800, height: 1.2, letterSpacing: -.02),
        titleMedium: _m(size: 15, weight: FontWeight.w700, height: 1.3, letterSpacing: -.01),
        titleSmall: _m(size: 13, weight: FontWeight.w700, height: 1.3, letterSpacing: -.01),
        bodyLarge: _m(size: 14, weight: FontWeight.w500, height: 1.6),
        bodyMedium: _m(size: 12.5, weight: FontWeight.w500, height: 1.55),
        bodySmall: _m(size: 11.5, weight: FontWeight.w500, height: 1.5),
        labelLarge: _m(size: 13, weight: FontWeight.w700, height: 1.2),
        labelMedium: _m(size: 11.5, weight: FontWeight.w600, height: 1.3),
        labelSmall: _m(size: 10, weight: FontWeight.w700, height: 1, letterSpacing: .1),
      );

  // ---------------------------------------------------------------------
  // Design-specific named styles
  // ---------------------------------------------------------------------

  /// Small uppercase kicker label, e.g. "MANAGING", "STEP 1 OF 4".
  static TextStyle get eyebrow => _m(
        size: 9.5,
        weight: FontWeight.w700,
        height: 1,
        letterSpacing: .12,
        color: AppColors.textMuted2,
      );

  /// Uppercase field label used in form inputs (e.g. "VISIT DATE",
  /// "HOSPITAL / CLINIC"). Slightly larger and noticeably darker than
  /// [eyebrow] — that style's light `textMuted2` all but disappears against
  /// the white field background, which is exactly what this exists to fix.
  static TextStyle get fieldLabel => _m(
        size: 11,
        weight: FontWeight.w700,
        height: 1,
        letterSpacing: .05,
        color: AppColors.textMuted5,
      );

  /// Large hero greeting on Home ("Let's start your health record, Rahul.").
  static TextStyle get heroTitle => _m(
        size: 27,
        weight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -.035,
        color: AppColors.ink,
      );

  /// Top-level screen title (Records / Vitals / Documents / Settings).
  static TextStyle get screenTitle => _m(
        size: 26,
        weight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -.035,
        color: AppColors.ink,
      );

  /// Detail-screen title (record detail, document viewer, onboarding step).
  static TextStyle get detailTitle => _m(
        size: 22,
        weight: FontWeight.w800,
        height: 1.25,
        letterSpacing: -.03,
        color: AppColors.ink,
      );

  /// Section header within a screen ("Needs attention", "Recent activity").
  static TextStyle get sectionTitle => _m(
        size: 15,
        weight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -.01,
        color: AppColors.ink,
      );

  /// Card / list-tile primary title.
  static TextStyle get cardTitle => _m(
        size: 13.5,
        weight: FontWeight.w600,
        height: 1.3,
        color: AppColors.ink,
      );

  /// Primary body copy (paragraphs, descriptions).
  static TextStyle get body => _m(
        size: 13,
        weight: FontWeight.w400,
        height: 1.65,
        color: AppColors.textMuted4,
      );

  /// Secondary body copy, slightly smaller / muted.
  static TextStyle get bodySecondary => _m(
        size: 11.5,
        weight: FontWeight.w500,
        height: 1.55,
        color: AppColors.textMuted3,
      );

  /// Caption / meta text (dates, counts, sub-labels).
  static TextStyle get caption => _m(
        size: 11,
        weight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textMuted,
      );

  /// Smallest caption, e.g. timestamps in a list.
  static TextStyle get captionSmall => _m(
        size: 10,
        weight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textMuted2,
      );

  /// Button / CTA label.
  static TextStyle get button => _m(
        size: 13,
        weight: FontWeight.w700,
        height: 1,
      );

  /// Chip / pill label.
  static TextStyle get chip => _m(
        size: 11.5,
        weight: FontWeight.w600,
        height: 1,
      );

  // -- Metrics (always tabular figures) ----------------------------------

  /// Huge metric, e.g. the 122/79 blood-pressure readout.
  static TextStyle get metricHero => _m(
        size: 46,
        weight: FontWeight.w800,
        height: 1,
        letterSpacing: -.045,
        color: AppColors.ink,
        tabularFigures: true,
      );

  /// Large metric, e.g. a vital-entry keypad value.
  static TextStyle get metricLarge => _m(
        size: 30,
        weight: FontWeight.w700,
        height: 1,
        letterSpacing: -.04,
        color: AppColors.ink,
        tabularFigures: true,
      );

  /// Medium metric, e.g. snapshot strip values.
  static TextStyle get metricMedium => _m(
        size: 21,
        weight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -.03,
        color: AppColors.ink,
        tabularFigures: true,
      );

  /// Small metric, e.g. stat-tile values.
  static TextStyle get metricSmall => _m(
        size: 16,
        weight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -.02,
        color: AppColors.ink,
        tabularFigures: true,
      );
}
