import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/hk_primary_button.dart';

/// Four-step onboarding flow — Welcome → Profile → Family → Privacy —
/// matching the redesign's `isOb` screen. Kept as `WelcomeScreen` (the
/// router already points `Routes.welcome` at this class); the name is
/// historical, the content is the full onboarding sequence. The design's
/// fifth step (optional Google Drive backup) is intentionally skipped —
/// there's no backend to back up to yet.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const _stepCount = 4;
  int _step = 0;

  final _nameController = TextEditingController();
  String? _bloodGroup;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_step == 1) return _nameController.text.trim().isNotEmpty;
    return true;
  }

  void _next() {
    if (_step == _stepCount - 1) {
      context.go(Routes.signIn);
      return;
    }
    setState(() => _step += 1);
  }

  void _skip() => context.go(Routes.signIn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(step: _step, stepCount: _stepCount),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .04),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(_step),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  if (_step < _stepCount - 1)
                    TextButton(
                      onPressed: _skip,
                      child: Text('Skip', style: AppTypography.button.copyWith(color: AppColors.textMuted)),
                    ),
                  Expanded(
                    child: HkPrimaryButton(
                      label: _ctaLabel(_step),
                      onPressed: _canContinue ? _next : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ctaLabel(int step) {
    if (step == 0) return 'Get started';
    if (step == _stepCount - 1) return 'Finish setup';
    return 'Continue';
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const _WelcomeStep();
      case 1:
        return _ProfileStep(
          nameController: _nameController,
          bloodGroup: _bloodGroup,
          onBloodGroupChanged: (v) => setState(() => _bloodGroup = v),
        );
      case 2:
        return const _FamilyStep();
      case 3:
      default:
        return const _PrivacyStep();
    }
  }
}

/// A row of thin, equal-width horizontal bars — filled for the current and
/// completed steps, faint for the ones still ahead — matching the design's
/// `obDots` segmented progress bar (a bar, not literal dots, despite the
/// name in the source).
class _ProgressBar extends StatelessWidget {
  final int step;
  final int stepCount;

  const _ProgressBar({required this.step, required this.stepCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        children: List.generate(stepCount, (i) {
          final filled = i <= step;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i == stepCount - 1 ? 0 : 5),
              decoration: BoxDecoration(
                color: filled ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Shared layout for every onboarding step: icon chip, eyebrow, title, body
/// copy, and an optional step-specific block underneath. Simple intro-style
/// steps are vertically and horizontally centered; the Profile step (which
/// holds an editable form) stays pinned to the top instead, so its fields
/// don't shift around as the keyboard opens.
class _StepScaffold extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String eyebrow;
  final String title;
  final String body;
  final Widget? extra;
  final bool centered;

  const _StepScaffold({
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.extra,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxis = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxis,
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.tint(iconColor, .14),
            borderRadius: BorderRadius.circular(AppDimens.radiusChip),
          ),
          child: Icon(icon, size: 30, color: iconColor),
        ),
        const SizedBox(height: 22),
        Text(eyebrow.toUpperCase(), style: AppTypography.eyebrow, textAlign: textAlign),
        const SizedBox(height: 10),
        Text(title, style: AppTypography.detailTitle.copyWith(fontSize: 25), textAlign: textAlign),
        const SizedBox(height: 10),
        Text(body, style: AppTypography.body, textAlign: textAlign),
        if (extra != null) ...[
          const SizedBox(height: 26),
          extra!,
        ],
      ],
    );

    if (!centered) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
      child: Center(child: SingleChildScrollView(child: content)),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return const _StepScaffold(
      icon: Icons.health_and_safety_outlined,
      eyebrow: 'Welcome',
      title: "One private place for your family's health history.",
      body: 'Visits, prescriptions, lab reports, vitals and documents — for '
          'everyone you look after, kept in one calm place.',
    );
  }
}

class _ProfileStep extends StatefulWidget {
  final TextEditingController nameController;
  final String? bloodGroup;
  final ValueChanged<String?> onBloodGroupChanged;

  const _ProfileStep({
    required this.nameController,
    required this.bloodGroup,
    required this.onBloodGroupChanged,
  });

  @override
  State<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<_ProfileStep> {
  DateTime? _dob;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(now.year - 110),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  InputBorder _fieldBorder(Color color, {double width = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.person_outline,
      eyebrow: 'Step 1 of 3',
      title: 'Start with your own profile.',
      body: 'This becomes your health space. You can add or change anything later.',
      centered: false,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your name', style: AppTypography.sectionTitle.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: widget.nameController,
            style: AppTypography.cardTitle,
            decoration: InputDecoration(
              hintText: 'e.g. Rahul Sharma',
              hintStyle: AppTypography.body,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: _fieldBorder(AppColors.border),
              enabledBorder: _fieldBorder(AppColors.border),
              focusedBorder: _fieldBorder(AppColors.primary, width: 1.5),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Date of birth (optional)', style: AppTypography.sectionTitle.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDob,
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppDimens.radiusTile),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted5),
                  const SizedBox(width: 10),
                  Text(
                    _dob == null ? 'Select date' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                    style: AppTypography.body.copyWith(color: _dob == null ? AppColors.textMuted : AppColors.ink),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Blood group (optional)', style: AppTypography.sectionTitle.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bloodGroups.map((g) {
              final selected = widget.bloodGroup == g;
              return _BloodGroupChip(
                label: g,
                selected: selected,
                onTap: () => widget.onBloodGroupChanged(selected ? null : g),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'Only name is required. Everything else can wait.',
            style: AppTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}

class _BloodGroupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BloodGroupChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          child: Text(
            label,
            style: AppTypography.chip.copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted5),
          ),
        ),
      ),
    );
  }
}

class _FamilyStep extends ConsumerWidget {
  const _FamilyStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(familyMembersProvider);

    return _StepScaffold(
      icon: Icons.group_outlined,
      iconColor: AppColors.hueOxygen,
      eyebrow: 'Step 2 of 3',
      title: 'Who else do you look after?',
      body: 'Each person gets a completely separate health space — separate '
          'records, vitals and documents.',
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in members) ...[
            _FamilyRow(name: m.name, subtitle: m.relation),
            const SizedBox(height: 8),
          ],
          _AddSomeoneButton(onTap: () => context.push(Routes.addFamilyMember)),
        ],
      ),
    );
  }
}

class _FamilyRow extends StatelessWidget {
  final String name;
  final String subtitle;
  const _FamilyRow({required this.name, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTypography.cardTitle.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.cardTitle),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 18, color: AppColors.success),
        ],
      ),
    );
  }
}

class _AddSomeoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSomeoneButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDashed),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 17, color: AppColors.textMuted5),
              const SizedBox(width: 6),
              Text('Add someone else', style: AppTypography.chip.copyWith(color: AppColors.textMuted5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyStep extends StatelessWidget {
  const _PrivacyStep();

  static const _points = [
    (
      Icons.smartphone_outlined,
      'Stored on this phone',
      'Records live in an encrypted local vault, not on our servers.',
    ),
    (
      Icons.no_accounts_outlined,
      'No account needed',
      'Use everything without signing up or giving an email.',
    ),
    (
      Icons.cloud_upload_outlined,
      'Backup is your choice',
      'If you turn it on, the copy goes to your Drive — not ours.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.lock_outline,
      iconColor: AppColors.hueGlucose,
      eyebrow: 'Step 3 of 3',
      title: 'Your health data stays yours.',
      body: 'No account. No sharing. Nothing leaves this phone unless you ask it to.',
      extra: Column(
        children: [
          for (final p in _points) ...[
            _PrivacyRow(icon: p.$1, title: p.$2, description: p.$3),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyRow({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        border: Border.all(color: AppColors.primarySoftBorder),
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.cardTitle),
                const SizedBox(height: 3),
                Text(description, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
