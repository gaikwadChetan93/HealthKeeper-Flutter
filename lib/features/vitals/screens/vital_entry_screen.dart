import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/widgets/confetti_overlay.dart';
import '../../../core/widgets/hk_primary_button.dart';
import '../config/vital_entry_spec.dart';
import '../widgets/vital_entry_record_builder.dart';

/// The redesign's fast path for logging a vital: a numeric keypad instead
/// of the generic form. Deliberately a separate flow from
/// [GenericFormScreen] — the 10 vitals never touch it.
class VitalEntryScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final int memberId;

  const VitalEntryScreen({super.key, required this.moduleKey, required this.memberId});

  @override
  ConsumerState<VitalEntryScreen> createState() => _VitalEntryScreenState();
}

class _VitalEntryScreenState extends ConsumerState<VitalEntryScreen> {
  late final spec = vitalEntrySpecs[widget.moduleKey]!;
  late final Map<String, String> _values = {for (final f in spec.fields) f.key: ''};
  int _focusedField = 0;
  int _selectedChip = 0;
  bool _saving = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  void _onKey(String k) {
    final field = spec.fields[_focusedField];
    var v = _values[field.key] ?? '';

    if (k == 'del') {
      v = v.isEmpty ? v : v.substring(0, v.length - 1);
    } else if (k == '.') {
      if (field.decimal && !v.contains('.') && v.isNotEmpty) v += '.';
    } else {
      final digitCount = v.replaceAll('.', '').length;
      if (digitCount < field.maxDigits) v = (v == '0' ? '' : v) + k;
    }

    setState(() {
      _values[field.key] = v;
      final digitCount = v.replaceAll('.', '').length;
      if (digitCount >= field.maxDigits && _focusedField < spec.fields.length - 1) {
        _focusedField++;
      }
    });
  }

  Future<void> _onSave() async {
    if (spec.fields.any((f) => (_values[f.key] ?? '').isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in every field first'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final chip = spec.chips.isNotEmpty ? spec.chips[_selectedChip] : null;
    buildAndSaveVitalRecord(
      ref: ref,
      moduleKey: widget.moduleKey,
      memberId: widget.memberId,
      values: _values,
      contextTag: chip,
    );

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(spec.cta.replaceFirst('Save ', 'Saved ').replaceFirst('Add ', 'Added ')), behavior: SnackBarBehavior.floating),
      );
      _confettiKey.currentState?.play();
      await Future.delayed(const Duration(milliseconds: 650));
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey)!;
    final hue = VitalModuleColors.getIconTint(widget.moduleKey);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConfettiOverlay(
        key: _confettiKey,
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _RoundButton(icon: Icons.arrow_back, onTap: () => context.pop()),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config.domainName, style: AppTypography.detailTitle.copyWith(fontSize: 18)),
                        Text('Today, ${DateFormat('h:mm a').format(DateTime.now())}', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < spec.fields.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: _FieldBox(
                            field: spec.fields[i],
                            value: _values[spec.fields[i].key] ?? '',
                            focused: i == _focusedField,
                            onTap: () => setState(() => _focusedField = i),
                          )),
                        ],
                      ],
                    ),
                    if (spec.chips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (var i = 0; i < spec.chips.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _EntryChip(
                                  label: spec.chips[i],
                                  selected: i == _selectedChip,
                                  onTap: () => setState(() => _selectedChip = i),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (spec.hint.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
                          const SizedBox(width: 7),
                          Expanded(child: Text(spec.hint, style: AppTypography.bodySecondary)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.7,
                      children: [
                        for (final k in const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'del'])
                          _KeypadButton(label: k == 'del' ? '⌫' : k, onTap: () => _onKey(k)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    HkPrimaryButton(label: spec.cta, loading: _saving, onPressed: _saving ? null : _onSave),
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
}

class _FieldBox extends StatelessWidget {
  final VitalEntryField field;
  final String value;
  final bool focused;
  final VoidCallback onTap;

  const _FieldBox({required this.field, required this.value, required this.focused, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          border: Border.all(color: focused ? AppColors.primary : AppColors.border, width: focused ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label.toUpperCase(), style: AppTypography.eyebrow.copyWith(letterSpacing: .03)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.isEmpty ? '—' : value,
                  style: AppTypography.metricLarge.copyWith(color: value.isEmpty ? AppColors.textFaint : AppColors.ink),
                ),
                const SizedBox(width: 4),
                Text(field.unit, style: AppTypography.captionSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EntryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.chip.copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted5),
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _KeypadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dividerFaint),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.metricSmall.copyWith(fontSize: 19)),
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
