import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/theme_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HealthKeeperApp extends ConsumerWidget {
  const HealthKeeperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Health Keeper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      // Android draws apps edge-to-edge behind its navigation buttons. Keep every
      // screen, sheet and dialog above them; the strip below matches the page.
      builder: (context, child) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(top: false, child: child!),
      ),
    );
  }
}
