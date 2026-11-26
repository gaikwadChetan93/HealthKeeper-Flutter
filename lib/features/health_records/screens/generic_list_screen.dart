import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/record_category_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/health_record.dart';
import '../../../core/widgets/hk_primary_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../config/module_screen_config.dart';

class GenericListScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final int memberId;

  const GenericListScreen({
    super.key,
    required this.moduleKey,
    required this.memberId,
  });

  @override
  ConsumerState<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends ConsumerState<GenericListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: ${widget.moduleKey}')));
    }

    final screenConfig = ModuleScreenConfig.getConfig(widget.moduleKey);
    final provider = screenConfig.getProvider(widget.memberId);
    final state = ref.watch(provider);
    final hue = RecordCategoryColors.getHue(widget.moduleKey);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
                  _RoundIconButton(icon: Icons.search, onTap: () => context.push(Routes.search)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.tint(hue),
                      borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                    ),
                    child: Icon(config.icon, size: 21, color: hue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config.domainName, style: AppTypography.screenTitle.copyWith(fontSize: 22)),
                        const SizedBox(height: 3),
                        Text(config.shortDescription, style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: AppTypography.body,
                        decoration: InputDecoration(
                          hintText: 'Search ${config.domainName.toLowerCase()}',
                          hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: state.records.when(
                loading: () => const ShimmerLoading(),
                error: (_, __) => _ErrorState(
                  moduleName: config.domainName.toLowerCase(),
                  onRetry: () => screenConfig.reload(ref, widget.memberId),
                ),
                data: (records) {
                  final filtered = _filterRecords(records, screenConfig);
                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(config.icon, size: 36, color: AppColors.textFaint),
                          const SizedBox(height: 14),
                          Text(config.emptyStateTitle, style: AppTypography.cardTitle, textAlign: TextAlign.center),
                          const SizedBox(height: 6),
                          Text(config.emptyStateDescription, style: AppTypography.bodySecondary, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final record = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RecordListCard(
                          title: screenConfig.getTitle(record),
                          subtitle: screenConfig.getSubtitle(record),
                          date: screenConfig.getDate(record),
                          hue: hue,
                          onTap: () => context.push(Routes.healthDetail(widget.moduleKey, record.id)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(Routes.healthAdd(widget.moduleKey, widget.memberId)),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  List<HealthRecord> _filterRecords(
    List<HealthRecord> records,
    ScreenConfig screenConfig,
  ) {
    if (_searchQuery.isEmpty) return records;
    final query = _searchQuery.toLowerCase();
    return records.where((r) {
      return screenConfig.getTitle(r).toLowerCase().contains(query) ||
          (screenConfig.getSubtitle(r)?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
}

class _RecordListCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final DateTime date;
  final Color hue;
  final VoidCallback onTap;

  const _RecordListCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.hue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title, style: AppTypography.cardTitle, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(DateFormat('d MMM yyyy').format(date), style: AppTypography.captionSmall),
                ],
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: AppTypography.bodySecondary, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String moduleName;
  final VoidCallback onRetry;
  const _ErrorState({required this.moduleName, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.textFaint),
          const SizedBox(height: 14),
          Text("Couldn't load $moduleName", style: AppTypography.cardTitle, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            'Something went wrong loading these records.',
            style: AppTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          HkPrimaryButton(label: 'Try again', icon: Icons.refresh, onPressed: onRetry, expand: false),
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
