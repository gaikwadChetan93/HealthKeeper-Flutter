import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/document_colors.dart';
import '../../../core/models/document.dart';
import '../../../core/state/active_person_provider.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';

/// The Documents tab: library of everything scanned for the active person,
/// with category filters and search, or the first-run state when there's
/// nothing scanned yet.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _query = '';
  DocumentCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(activePersonProvider);
    final memberId = ref.watch(activePersonIdOrFallbackProvider);
    final docsRecords = ref.watch(documentProvider(memberId)).records;
    final docs = docsRecords.valueOrNull ?? const <Document>[];

    if (docsRecords.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (person?.name ?? '').toUpperCase(),
                  style: AppTypography.eyebrow.copyWith(letterSpacing: .12),
                ),
                const SizedBox(height: 7),
                Text('Documents', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
                const SizedBox(height: 18),
                const Expanded(child: ShimmerLoading()),
              ],
            ),
          ),
        ),
      );
    }

    if (docs.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (person?.name ?? '').toUpperCase(),
                  style: AppTypography.eyebrow.copyWith(letterSpacing: .12),
                ),
                const SizedBox(height: 7),
                Text('Documents', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
                const SizedBox(height: 22),
                _FreshDocumentsCard(
                  onScan: () => context.push(Routes.scannerCapture(memberId)),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusTile),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 19, color: AppColors.textMuted5),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          "Start with the paperwork already in your drawer — old prescriptions and last year's blood test are the ones you'll want first.",
                          style: AppTypography.bodySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = docs.where((d) {
      if (_filter != null && d.category != _filter) return false;
      if (_query.isEmpty) return true;
      return d.title.toLowerCase().contains(_query.toLowerCase());
    }).toList()
      ..sort((a, b) => b.scannedDate.compareTo(a.scannedDate));

    final categoriesUsed = docs.map((d) => d.category).toSet().length;
    final thisMonth = docs.where((d) {
      final now = DateTime.now();
      return d.scannedDate.year == now.year && d.scannedDate.month == now.month;
    }).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (person?.name ?? '').toUpperCase(),
                          style: AppTypography.eyebrow.copyWith(letterSpacing: .12),
                        ),
                        const SizedBox(height: 7),
                        Text('Documents', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
                      ],
                    ),
                    _RoundIconButton(
                      icon: Icons.document_scanner_outlined,
                      onTap: () => context.push(Routes.scannerCapture(memberId)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
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
                            hintText: 'Search reports, prescriptions, bills',
                            hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == null,
                      hue: AppColors.textMuted5,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final c in DocumentCategory.values) ...[
                      const SizedBox(width: 7),
                      _FilterChip(
                        label: c.displayName,
                        selected: _filter == c,
                        hue: DocumentColors.getHue(c),
                        onTap: () => setState(() => _filter = c),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              sliver: filtered.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text('No documents match', style: AppTypography.bodySecondary),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _DocumentCard(
                          document: filtered[i],
                          onTap: () => context.push(Routes.documentDetail(filtered[i].id)),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                child: Row(
                  children: [
                    Expanded(child: _StatTile(value: '${docs.length}', label: 'Documents')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatTile(value: '$categoriesUsed', label: 'Categories')),
                    const SizedBox(width: 8),
                    Expanded(child: _StatTile(value: '$thisMonth', label: 'This month')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreshDocumentsCard extends StatelessWidget {
  final VoidCallback onScan;
  const _FreshDocumentsCard({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusCardL),
      ),
      child: Column(
        children: [
          const Icon(Icons.description_outlined, size: 40, color: AppColors.textFaint),
          const SizedBox(height: 14),
          Text('No documents yet', style: AppTypography.cardTitle.copyWith(fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 9),
          Text(
            'Scan a prescription, lab report or bill. Health Keeper crops the page, reads the details, and files it under the right person.',
            style: AppTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onScan,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
              ),
              alignment: Alignment.center,
              child: Text('Scan your first document', style: AppTypography.button.copyWith(color: AppColors.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;

  const _DocumentCard({required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = DocumentColors.getHue(document.category);
    final firstPage = document.pagePaths.isNotEmpty ? document.pagePaths.first : null;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                        child: firstPage != null
                            ? Image.file(File(firstPage), fit: BoxFit.cover)
                            : Container(
                                color: AppColors.surfaceMuted,
                                alignment: Alignment.center,
                                child: Icon(document.category.icon, size: 26, color: hue.withValues(alpha: .7)),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          document.category.displayName.toUpperCase(),
                          style: AppTypography.captionSmall.copyWith(color: hue, fontWeight: FontWeight.w700, fontSize: 8.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                document.title,
                style: AppTypography.cardTitle.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(DateFormat('d MMM yyyy').format(document.scannedDate), style: AppTypography.captionSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 3),
          Text(label, style: AppTypography.captionSmall),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color hue;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.hue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.tint(hue) : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? hue : AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.chip.copyWith(color: selected ? hue : AppColors.textMuted5),
          ),
        ),
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
        child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: AppColors.textMuted5)),
      ),
    );
  }
}
