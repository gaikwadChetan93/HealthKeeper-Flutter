import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/record_category_colors.dart';
import '../../../app/route_constants.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/state/record_lookup.dart';
import '../../../core/widgets/hk_card.dart';
import '../config/module_screen_config.dart';

class GenericDetailScreen extends ConsumerWidget {
  final String moduleKey;
  final int recordId;

  const GenericDetailScreen({
    super.key,
    required this.moduleKey,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ModuleRegistry.getModuleByKey(moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: $moduleKey')));
    }

    final screenConfig = ModuleScreenConfig.getConfig(moduleKey);
    final record = findRecordById(ref, moduleKey, recordId);
    final hue = RecordCategoryColors.getHue(moduleKey);

    if (record == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [_RoundIconButton(icon: Icons.arrow_back, onTap: () => context.pop())],
                ),
              ),
              Expanded(
                child: Center(child: Text('This record was not found', style: AppTypography.body)),
              ),
            ],
          ),
        ),
      );
    }

    final members = ref.watch(familyMembersProvider);
    final person = members.where((m) => m.id == record.familyMemberId).firstOrNull;
    final rows = screenConfig.getDetailRows(record);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
                  _RoundIconButton(
                    icon: Icons.edit_outlined,
                    onTap: () => context.push(
                      Routes.healthEdit(moduleKey, record.familyMemberId, record.id),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.tint(hue),
                        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(config.icon, size: 14, color: hue),
                          const SizedBox(width: 6),
                          Text(
                            config.domainName,
                            style: AppTypography.captionSmall.copyWith(color: hue, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      screenConfig.getTitle(record),
                      style: AppTypography.screenTitle.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      [
                        DateFormat('EEE d MMM yyyy').format(screenConfig.getDate(record)),
                        if (person != null) 'for ${person.name}',
                      ].join(' · '),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 20),
                    HkCard(
                      padding: EdgeInsets.zero,
                      showShadow: false,
                      child: Column(
                        children: [
                          for (var i = 0; i < rows.length; i++)
                            _DetailRow(label: rows[i].key, value: rows[i].value, isLast: i == rows.length - 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            "Kept in this person's space on this phone.",
                            style: AppTypography.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
                        onTap: () => _showDeleteDialog(context, ref, screenConfig, record.familyMemberId),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.errorBorder),
                            borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
                          ),
                          alignment: Alignment.center,
                          child: Text('Delete', style: AppTypography.button.copyWith(color: AppColors.error)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ScreenConfig screenConfig, int memberId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await screenConfig.simulateDelete(ref, memberId);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Record deleted'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({required this.label, required this.value, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.dividerFaint)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label, style: AppTypography.eyebrow.copyWith(letterSpacing: .02)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 19, color: AppColors.textMuted5)),
      ),
    );
  }
}
