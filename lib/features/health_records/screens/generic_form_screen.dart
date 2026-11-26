import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/record_category_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/state/form_state_notifier.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../../core/widgets/hk_card.dart';
import '../../../core/widgets/hk_primary_button.dart';
import '../config/module_screen_config.dart';
import '../widgets/field_renderer.dart';

/// The 5 record types the design gives a "scan to fill this in" header —
/// each one is normally backed by a physical document (prescription note,
/// lab report, imaging report, discharge summary, vaccination certificate).
/// The header here is UI only; the camera/OCR flow itself is Phase 5.
const _scanBackedModules = <String>{
  'medical_visit',
  'lab_result',
  'radiology_result',
  'surgery',
  'vaccine',
};

class GenericFormScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final int memberId;
  final int? recordId;

  const GenericFormScreen({
    super.key,
    required this.moduleKey,
    required this.memberId,
    this.recordId,
  });

  @override
  ConsumerState<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends ConsumerState<GenericFormScreen> {
  bool _showAdvanced = false;
  bool get isEditMode => widget.recordId != null;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: ${widget.moduleKey}')));
    }

    final formState = ref.watch(formStateProvider);
    final formNotifier = ref.read(formStateProvider.notifier);
    final hue = RecordCategoryColors.getHue(widget.moduleKey);

    final coreFields = config.fields.where((f) => !f.isAdvanced).toList();
    final advancedFields = config.fields.where((f) => f.isAdvanced).toList();
    final showScanHeader = !isEditMode && _scanBackedModules.contains(widget.moduleKey);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConfettiOverlay(
        key: _confettiKey,
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _RoundBackButton(onTap: () => context.pop()),
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.tint(hue),
                      borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                    ),
                    child: Icon(config.icon, size: 18, color: hue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'Edit ${config.domainName}' : config.domainName,
                    style: AppTypography.detailTitle.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showScanHeader) ...[
                      _ScanHeader(hue: hue, domainName: config.domainName),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.dividerFaint, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'OR ENTER BY HAND',
                              style: AppTypography.eyebrow.copyWith(letterSpacing: .1),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.dividerFaint, height: 1)),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    HkCard(
                      padding: EdgeInsets.zero,
                      showShadow: false,
                      child: Column(
                        children: _buildFieldRows(coreFields, formState, formNotifier),
                      ),
                    ),

                    if (advancedFields.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                _showAdvanced ? Icons.expand_less : Icons.expand_more,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _showAdvanced ? 'Show less' : 'Show more',
                                style: AppTypography.button.copyWith(color: AppColors.primary, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showAdvanced) ...[
                        const SizedBox(height: 8),
                        HkCard(
                          padding: EdgeInsets.zero,
                          showShadow: false,
                          child: Column(
                            children: _buildFieldRows(advancedFields, formState, formNotifier),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            "Saved to this person's space on this phone.",
                            style: AppTypography.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    HkPrimaryButton(
                      label: isEditMode ? 'Update' : 'Save',
                      loading: formState.isSubmitting,
                      onPressed: formState.isSubmitting
                          ? null
                          : () => _onSave(config.fields, formNotifier),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  List<Widget> _buildFieldRows(
    List<FieldDescriptor> fields,
    FormDataState formState,
    FormStateNotifier formNotifier,
  ) {
    final widgets = <Widget>[];
    var i = 0;

    while (i < fields.length) {
      final field = fields[i];
      final isLast = i == fields.length - 1 ||
          (field.layoutWidth == LayoutWidth.half &&
              i + 1 < fields.length &&
              fields[i + 1].layoutWidth == LayoutWidth.half &&
              i + 2 >= fields.length);

      if (field.layoutWidth == LayoutWidth.half &&
          i + 1 < fields.length &&
          fields[i + 1].layoutWidth == LayoutWidth.half) {
        widgets.add(_FieldRow(
          isLast: isLast,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FieldRenderer(
                  descriptor: field,
                  value: formState.formData[field.key],
                  error: formState.formErrors[field.key],
                  onChanged: (v) => formNotifier.updateField(field.key, v),
                ),
              ),
              const SizedBox(width: AppDimens.spacingL),
              Expanded(
                child: FieldRenderer(
                  descriptor: fields[i + 1],
                  value: formState.formData[fields[i + 1].key],
                  error: formState.formErrors[fields[i + 1].key],
                  onChanged: (v) => formNotifier.updateField(fields[i + 1].key, v),
                ),
              ),
            ],
          ),
        ));
        i += 2;
      } else {
        widgets.add(_FieldRow(
          isLast: isLast,
          child: FieldRenderer(
            descriptor: field,
            value: formState.formData[field.key],
            error: formState.formErrors[field.key],
            onChanged: (v) => formNotifier.updateField(field.key, v),
          ),
        ));
        i++;
      }
    }
    return widgets;
  }

  Future<void> _onSave(
    List<FieldDescriptor> fields,
    FormStateNotifier notifier,
  ) async {
    if (!notifier.validate(fields)) return;

    notifier.setSubmitting(true);
    final screenConfig = ModuleScreenConfig.getConfig(widget.moduleKey);
    await screenConfig.simulateSave(ref, widget.memberId);
    notifier.setSubmitting(false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Record updated' : 'Record saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (!isEditMode) {
        // Celebrate a genuinely new record — briefly, so the burst is
        // visible before the screen pops away. Edits skip it; updating an
        // existing record isn't the same kind of win as adding one.
        _confettiKey.currentState?.play();
        await Future.delayed(const Duration(milliseconds: 650));
      }
      if (mounted) context.pop();
    }
  }
}

class _FieldRow extends StatelessWidget {
  final Widget child;
  final bool isLast;

  const _FieldRow({required this.child, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.dividerFaint)),
      ),
      child: child,
    );
  }
}

class _ScanHeader extends StatelessWidget {
  final Color hue;
  final String domainName;

  const _ScanHeader({required this.hue, required this.domainName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        border: Border.all(color: AppColors.primarySoftBorder),
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusChip),
            ),
            child: const Icon(Icons.document_scanner_outlined, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan to fill this in', style: AppTypography.sectionTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Health Keeper reads the page and fills the fields below — you only check them.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    _ScanAction(
                      icon: Icons.photo_camera_outlined,
                      label: 'Scan now',
                      filled: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scanning lands in a later phase'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 7),
                    _ScanAction(
                      icon: Icons.attach_file,
                      label: 'Pick a file',
                      filled: false,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File import lands in a later phase'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ScanAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: filled ? null : Border.all(color: AppColors.primarySoftBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: filled ? AppColors.onPrimary : AppColors.textMuted5),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.chip.copyWith(
                  color: filled ? AppColors.onPrimary : AppColors.textMuted5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.arrow_back, size: 19, color: AppColors.textMuted5),
        ),
      ),
    );
  }
}
