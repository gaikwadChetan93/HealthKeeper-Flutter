import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';
import 'app/theme/app_typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadFonts();
  runApp(const ProviderScope(child: HealthKeeperApp()));
}

/// Loads Manrope before the first frame. Screens that fit-or-scroll measure
/// their text up front; measured in the fallback font and drawn in Manrope,
/// a line can wrap differently and the screen overflows. After the first
/// launch the font comes from the device's cache, so this is quick.
Future<void> _loadFonts() async {
  try {
    await GoogleFonts.pendingFonts([AppTypography.textTheme])
        .timeout(const Duration(seconds: 3));
  } catch (_) {
    // Offline on the very first launch: carry on with the fallback font.
  }
}
