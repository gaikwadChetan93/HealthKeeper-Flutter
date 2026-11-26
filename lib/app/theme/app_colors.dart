import 'package:flutter/material.dart';

/// Health Keeper redesign palette — forest green (#1E4D3B) on bone (#F2EEE6).
///
/// Tokens are named by role (background / surface / border / ink / muted)
/// rather than by raw hue, so screens read `AppColors.ink` instead of a hex
/// literal. Source of truth: the Claude Design export's `Health Keeper.dc.html`.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------

  /// Primary brand green. Buttons, active tab, links, focus rings.
  static const primary = Color(0xFF1E4D3B);

  /// Pressed / hovered state of [primary].
  static const primaryDark = Color(0xFF143329);

  /// Tinted green surface used behind chips, badges and the "Active" pill.
  static const primaryContainer = Color(0xFFE7EEE9);

  /// Slightly deeper tinted green surface used for privacy/trust callouts.
  static const primarySoft = Color(0xFFEAF0EB);

  /// Border colour paired with [primarySoft] callouts.
  static const primarySoftBorder = Color(0xFFD8E3DB);

  /// Off-white text/icons drawn on top of [primary] or [inkStrong].
  static const onPrimary = Color(0xFFF7F4EE);

  // Backward-compatible aliases used before the redesign.
  static const primaryLight = primaryContainer;

  // ---------------------------------------------------------------------
  // Background / surface / border
  // ---------------------------------------------------------------------

  /// App canvas colour ("bone"). Scaffold background.
  static const background = Color(0xFFF2EEE6);

  /// Card / sheet / list-tile fill.
  static const surface = Color(0xFFFFFFFF);

  /// Neutral warm surface used for stat tiles, tag chips, subtle callouts.
  static const surfaceMuted = Color(0xFFEFEBE1);

  /// Hairline border around cards and tiles.
  static const border = Color(0xFFE3DED3);

  /// Lighter divider between rows inside a card.
  static const divider = Color(0xFFEDE9DF);

  /// Even lighter divider used inside dense field lists.
  static const dividerFaint = Color(0xFFF3F0E8);

  /// Dashed-border colour for "add" affordances.
  static const borderDashed = Color(0xFFCFC8BA);

  // ---------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------

  /// Primary reading text ("ink").
  static const ink = Color(0xFF17211C);

  /// Deepest ink — used for dark surfaces (splash, doc viewer, scanner bg).
  static const inkStrong = Color(0xFF143329);

  /// Secondary text — captions, meta rows, muted labels.
  static const textMuted = Color(0xFF8A9490);

  /// Tertiary text — dates, eyebrow labels, timestamps.
  static const textMuted2 = Color(0xFFA6ACA5);

  /// Body copy in secondary paragraphs (onboarding, empty states).
  static const textMuted3 = Color(0xFF6E7873);

  /// Slightly darker muted body text.
  static const textMuted4 = Color(0xFF5A655F);

  /// Default icon / label colour on nav and secondary actions.
  static const textMuted5 = Color(0xFF4C5852);

  /// Faint text — chevrons, disabled affordances.
  static const textFaint = Color(0xFFC2C8C2);

  /// Faintest text — chart axis labels.
  static const textFaint2 = Color(0xFFB4BAB4);

  // ---------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------

  static const success = Color(0xFF2F6B4F);
  static const successBg = Color(0xFFE7EEE9);

  static const warning = Color(0xFF8C5F22);
  static const warningBg = Color(0xFFF8EFE3);
  static const warningSurface = Color(0xFFFBF6EE);
  static const warningBorder = Color(0xFFEADCC6);

  static const error = Color(0xFFA2402F);
  static const errorBg = Color(0xFFFCF6F4);
  static const errorBorder = Color(0xFFE7D3CE);

  // ---------------------------------------------------------------------
  // Dark surfaces (splash / scanner / document viewer)
  // ---------------------------------------------------------------------

  static const splashBackground = Color(0xFF143329);
  static const scannerBackground = Color(0xFF0D1310);
  static const scannerGlow = Color(0xFF25302A);
  static const scanGuide = Color(0xFF9BC7AC);

  // ---------------------------------------------------------------------
  // Accent hues — shared across vital tiles and record categories
  // ---------------------------------------------------------------------

  static const hueBloodPressure = Color(0xFFB4553F);
  static const hueHeartRate = Color(0xFFA8455C);
  static const hueGlucose = Color(0xFF7A5AA0);
  static const hueOxygen = Color(0xFF3D6E8F);
  static const hueWeight = Color(0xFF2F6B4F);
  static const hueTemperature = Color(0xFFB07C3A);
  static const hueSleep = Color(0xFF4F5B9E);
  static const hueHydration = Color(0xFF3D8B8B);
  static const hueActivity = Color(0xFF5E7C3A);
  static const hueDocument = Color(0xFF6E7873);

  /// Blends [hue] over white the way the design's `color-mix(in oklab, hue
  /// X%, #fff)` produces soft icon-chip backgrounds. `amount` is the
  /// proportion of [hue] mixed in (design typically uses 0.10–0.16).
  static Color tint(Color hue, [double amount = 0.13]) {
    return Color.alphaBlend(hue.withValues(alpha: amount), surface);
  }

  // ---------------------------------------------------------------------
  // Legacy / still-referenced tokens (retuned to the new palette)
  // ---------------------------------------------------------------------

  static const mediumGray = textMuted;
  static const darkGray = ink;

  static const darkSurface = Color(0xFF12181C);
  static const darkSurfaceVariant = Color(0xFF1B2420);
  static const darkOnSurfaceVariant = Color(0xFFAEB8B2);

  static const avatarColors = [
    hueWeight,
    hueGlucose,
    hueTemperature,
    hueOxygen,
    hueSleep,
    hueHeartRate,
  ];

  static const zoneCriticalLow = error;
  static const zoneWarning = warning;
  static const zoneNormal = success;
  static const zoneCriticalHigh = error;

  static const paywallPurple = Color(0xFF7A5AA0);
  static const paywallPink = Color(0xFFA8455C);
  static const paywallYellow = Color(0xFFB07C3A);

  static const syncPending = warning;
  static const syncFailed = error;
  static const syncSuccess = success;

  /// Get avatar color by index (cycles through palette).
  static Color getAvatarColor(int index) =>
      avatarColors[index % avatarColors.length];

  // ---------------------------------------------------------------------
  // Material ColorScheme
  // ---------------------------------------------------------------------

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: primary,
    secondary: hueOxygen,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDCE7EC),
    onSecondaryContainer: Color(0xFF17323F),
    surface: surface,
    onSurface: ink,
    surfaceContainerHighest: background,
    onSurfaceVariant: textMuted,
    error: error,
    onError: Colors.white,
    outline: border,
    outlineVariant: divider,
    inverseSurface: inkStrong,
    onInverseSurface: onPrimary,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9BC7AC),
    onPrimary: Color(0xFF0D1F16),
    primaryContainer: Color(0xFF24392E),
    onPrimaryContainer: Color(0xFFCFE8D8),
    secondary: Color(0xFF8FB6C9),
    onSecondary: Color(0xFF0D1F16),
    secondaryContainer: Color(0xFF223842),
    onSecondaryContainer: Color(0xFFD6E7EC),
    surface: darkSurface,
    onSurface: Color(0xFFEDEAE1),
    surfaceContainerHighest: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    error: Color(0xFFE5A498),
    onError: Color(0xFF3A0A03),
    outline: Color(0xFF3A443E),
    outlineVariant: Color(0xFF2A322D),
    inverseSurface: Color(0xFFEDEAE1),
    onInverseSurface: darkSurface,
  );
}
