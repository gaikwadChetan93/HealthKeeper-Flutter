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
import '../../../core/state/form_state_notifier.dart';
import '../../../core/state/module_providers.dart';

/// Maps a document category to the closest existing health-record module,
/// for the "Save as <record>" handoff. Categories with no clean match
/// (bill, insurance, other) return null — the viewer just doesn't offer
/// that action for them rather than forcing a bad fit.
String? _suggestedModuleKey(DocumentCategory category) => switch (category) {
      DocumentCategory.labReport => 'lab_result',
      DocumentCategory.prescription => 'prescription',
      DocumentCategory.radiology => 'radiology_result',
      DocumentCategory.vaccineCertificate => 'vaccine',
      DocumentCategory.bill => null,
      DocumentCategory.insurance => null,
      DocumentCategory.other => null,
    };

String _suggestedModuleName(String moduleKey) => switch (moduleKey) {
      'lab_result' => 'lab result',
      'prescription' => 'prescription',
      'radiology_result' => 'imaging result',
      'vaccine' => 'vaccine',
      _ => 'record',
    };

class DocumentDetailScreen extends ConsumerStatefulWidget {
  final int documentId;
  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(familyMembersProvider);
    Document? doc;
    for (final member in members) {
      final records = ref.watch(documentProvider(member.id)).records.valueOrNull;
      final match = records?.where((d) => d.id == widget.documentId).firstOrNull;
      if (match != null) {
        doc = match;
        break;
      }
    }

    if (doc == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(children: [_RoundButton(icon: Icons.arrow_back, onTap: () => context.pop())]),
              ),
              Expanded(child: Center(child: Text('This document was not found', style: AppTypography.body))),
            ],
          ),
        ),
      );
    }

    final document = doc;
    final hue = DocumentColors.getHue(document.category);
    final ocrLines = (document.ocrText ?? '')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final suggestedModule = _suggestedModuleKey(document.category);

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
                  _RoundButton(icon: Icons.arrow_back, onTap: () => context.pop()),
                  _RoundButton(
                    icon: Icons.drive_file_rename_outline,
                    onTap: () => _rename(document),
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
                          Icon(document.category.icon, size: 14, color: hue),
                          const SizedBox(width: 6),
                          Text(
                            document.category.displayName,
                            style: AppTypography.captionSmall.copyWith(color: hue, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(document.title, style: AppTypography.screenTitle.copyWith(fontSize: 21)),
                    const SizedBox(height: 6),
                    Text(
                      [
                        DateFormat('d MMM yyyy').format(document.scannedDate),
                        if (document.pagePaths.isNotEmpty)
                          '${document.pagePaths.length} page${document.pagePaths.length == 1 ? '' : 's'}',
                        if (document.pagePaths.isNotEmpty) 'scanned in Health Keeper',
                      ].join(' · '),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 16),
                    _PageViewer(document: document, pageIndex: _pageIndex, onPageChanged: (i) => setState(() => _pageIndex = i)),
                    const SizedBox(height: 18),
                    if (ocrLines.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppDimens.radiusTile),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Read from the scan', style: AppTypography.cardTitle.copyWith(fontSize: 12.5)),
                                        const SizedBox(height: 2),
                                        Text('Recognised on device · check before saving', style: AppTypography.captionSmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (var i = 0; i < ocrLines.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                                decoration: BoxDecoration(
                                  border: i == ocrLines.length - 1
                                      ? null
                                      : const Border(bottom: BorderSide(color: AppColors.dividerFaint)),
                                ),
                                child: Text(ocrLines[i], style: AppTypography.body),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        if (suggestedModule != null)
                          Expanded(
                            flex: 2,
                            child: _PrimaryAction(
                              label: 'Save as ${_suggestedModuleName(suggestedModule)}',
                              onTap: () => _saveAsRecord(document, suggestedModule),
                            ),
                          ),
                        if (suggestedModule != null) const SizedBox(width: 9),
                        Expanded(
                          child: _SecondaryAction(label: 'Delete', onTap: () => _confirmDelete(document)),
                        ),
                      ],
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

  void _saveAsRecord(Document document, String moduleKey) {
    ref.read(formStateProvider.notifier).prefillForm({'notes': document.ocrText ?? ''});
    context.push(Routes.healthAdd(moduleKey, document.familyMemberId));
  }

  void _rename(Document document) {
    final controller = TextEditingController(text: document.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                final notifier = ref.read(documentProvider(document.familyMemberId).notifier);
                notifier.removeRecord(document.id);
                notifier.addRecord(document.copyWith(title: newTitle));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Document document) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(documentProvider(document.familyMemberId).notifier).removeRecord(document.id);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PageViewer extends StatelessWidget {
  final Document document;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;

  const _PageViewer({required this.document, required this.pageIndex, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final pages = document.pagePaths;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkStrong,
        borderRadius: BorderRadius.circular(AppDimens.radiusCardL - 4),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusTile),
              child: pages.isEmpty
                  ? Container(
                      color: AppColors.surfaceMuted,
                      alignment: Alignment.center,
                      child: Icon(document.category.icon, size: 40, color: AppColors.textFaint),
                    )
                  : PageView.builder(
                      itemCount: pages.length,
                      onPageChanged: onPageChanged,
                      itemBuilder: (_, i) => Image.file(File(pages[i]), fit: BoxFit.contain),
                    ),
            ),
          ),
          if (pages.length > 1) ...[
            const SizedBox(height: 8),
            Text('${pageIndex + 1} / ${pages.length}', style: AppTypography.captionSmall.copyWith(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.button.copyWith(color: AppColors.onPrimary), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.errorBorder),
            borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.button.copyWith(color: AppColors.error)),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

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
