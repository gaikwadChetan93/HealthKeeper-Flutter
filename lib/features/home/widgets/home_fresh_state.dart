import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/hk_card.dart';

/// First-run Home state for a person with no vitals and no records yet —
/// the design's "Let's start your health record" screen: a 3-step setup
/// card and a preview of what the tab will show once they begin.
class HomeFreshState extends StatelessWidget {
  final String firstName;
  final int memberId;
  final VoidCallback onAddVital;

  const HomeFreshState({super.key, required this.firstName, required this.memberId, required this.onAddVital});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Let's start your health record, $firstName.", style: AppTypography.heroTitle),
        const SizedBox(height: 10),
        Text(
          "Nothing is here yet — that's expected. Three small steps and this screen starts working for you.",
          style: AppTypography.body,
        ),
        const SizedBox(height: 20),
        HkCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                child: Text('Set up in 3 steps', style: AppTypography.sectionTitle.copyWith(fontSize: 12.5)),
              ),
              _SetupStep(
                icon: Icons.monitor_heart_outlined,
                title: 'Add your first vital',
                subtitle: 'Blood pressure, weight or whatever you track',
                cta: 'Add',
                onTap: onAddVital,
              ),
              _SetupStep(
                icon: Icons.document_scanner_outlined,
                title: 'Scan a document',
                subtitle: 'A prescription or an old lab report',
                cta: 'Scan',
                onTap: () => context.push(Routes.scannerCapture(memberId)),
              ),
              _SetupStep(
                icon: Icons.group_outlined,
                title: 'Add a family member',
                subtitle: 'Give each person their own private space',
                cta: 'Add',
                onTap: () => context.push(Routes.family),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('What lives here once you begin', style: AppTypography.sectionTitle.copyWith(fontSize: 14)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: 1.6,
          children: const [
            _PreviewTile(icon: Icons.monitor_heart_outlined, hue: AppColors.hueBloodPressure, title: 'Your vitals, charted', description: 'See at a glance whether a number is holding steady'),
            _PreviewTile(icon: Icons.history, hue: AppColors.hueDocument, title: 'A searchable history', description: 'Find a visit from two years ago in seconds'),
            _PreviewTile(icon: Icons.description_outlined, hue: AppColors.hueTemperature, title: 'Every document', description: 'Scanned, cropped and filed by type'),
            _PreviewTile(icon: Icons.group_outlined, hue: AppColors.hueActivity, title: 'The whole family', description: 'Separate spaces, one switch away'),
          ],
        ),
        const SizedBox(height: 20),
        HkCard(
          color: AppColors.primarySoft,
          borderColor: AppColors.primarySoftBorder,
          showShadow: false,
          onTap: () => context.push(Routes.privacyAndData),
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Everything you add stays on this phone', style: AppTypography.cardTitle),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}

class _SetupStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;
  final bool isLast;

  const _SetupStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(top: BorderSide(color: AppColors.dividerFaint)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(icon, size: 15, color: AppColors.textMuted5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.cardTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              ),
              child: Text(cta, style: AppTypography.captionSmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  final IconData icon;
  final Color hue;
  final String title;
  final String description;

  const _PreviewTile({
    required this.icon,
    required this.hue,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: hue),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 12.5)),
          const SizedBox(height: 3),
          Text(
            description,
            style: AppTypography.captionSmall.copyWith(fontWeight: FontWeight.w500, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
