import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/route_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../features/home/widgets/add_sheet.dart';

/// The redesign's bottom nav: Home / Records / (centre Add) / Vitals /
/// Docs, floating as a rounded white pill over the content. Family,
/// Doctors and Settings — the old three tabs — moved out; they're reachable
/// from Settings and the person picker now.
///
/// The centre button doesn't navigate — it opens the add sheet as a modal,
/// matching the design (`isAdd` tabs call `openAdd`, not `go`).
class BottomNavShell extends ConsumerStatefulWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  @override
  ConsumerState<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends ConsumerState<BottomNavShell> {
  bool _addOpen = false;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(Routes.records)) return 1;
    if (location.startsWith(Routes.vitals)) return 2;
    if (location.startsWith(Routes.documents)) return 3;
    return 0;
  }

  Future<void> _openAdd(BuildContext context) async {
    setState(() => _addOpen = true);
    await showAddSheet(context, ref);
    if (mounted) setState(() => _addOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Color(0x0D17211C), offset: Offset(0, 2), blurRadius: 4),
              BoxShadow(color: Color(0x6617211C), offset: Offset(0, 16), blurRadius: 30, spreadRadius: -20),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                filledIcon: Icons.home,
                label: 'Home',
                selected: index == 0,
                onTap: () => context.go(Routes.home),
              ),
              _NavItem(
                icon: Icons.folder_open_outlined,
                filledIcon: Icons.folder_open,
                label: 'Records',
                selected: index == 1,
                onTap: () => context.go(Routes.records),
              ),
              _AddButton(open: _addOpen, onTap: () => _openAdd(context)),
              _NavItem(
                icon: Icons.monitor_heart_outlined,
                filledIcon: Icons.monitor_heart,
                label: 'Vitals',
                selected: index == 2,
                onTap: () => context.go(Routes.vitals),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                filledIcon: Icons.description,
                label: 'Docs',
                selected: index == 3,
                onTap: () => context.go(Routes.documents),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? filledIcon : icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.captionSmall.copyWith(color: color, letterSpacing: .01),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const _AddButton({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimens.radiusChip + 4),
              boxShadow: const [
                BoxShadow(color: Color(0xCC1E4D3B), offset: Offset(0, 6), blurRadius: 14, spreadRadius: -6),
              ],
            ),
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.add, color: AppColors.onPrimary, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}
