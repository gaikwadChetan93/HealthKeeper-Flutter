import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/doctor.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/state/doctor_providers.dart';
import '../../../core/widgets/load_error_view.dart';

/// A record's doctor field: type a name, or pick one of the family's saved
/// doctors to link the record to them. A new name can be saved as a doctor.
class DoctorPickerField extends ConsumerStatefulWidget {
  final FieldDescriptor descriptor;
  final String? name;
  final String? doctorId;
  final String? error;

  /// The name as typed or picked, and the linked doctor's id (null if none).
  final void Function(String? name, String? doctorId) onChanged;

  /// Called when a saved doctor is picked (e.g. to fill in their clinic).
  final ValueChanged<Doctor>? onPicked;

  const DoctorPickerField({
    super.key,
    required this.descriptor,
    required this.name,
    required this.doctorId,
    required this.onChanged,
    this.onPicked,
    this.error,
  });

  @override
  ConsumerState<DoctorPickerField> createState() => _DoctorPickerFieldState();
}

class _DoctorPickerFieldState extends ConsumerState<DoctorPickerField> {
  late final _controller = TextEditingController(text: widget.name ?? '');
  final _focus = FocusNode();
  late String? _doctorId = widget.doctorId;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _pick(Doctor d) {
    _controller.text = d.name;
    setState(() => _doctorId = d.id);
    widget.onChanged(d.name, d.id);
    widget.onPicked?.call(d);
  }

  void _typed(String text, List<Doctor> doctors) {
    // Typing the exact name of a saved doctor links to them; anything else unlinks.
    final match = doctors
        .where((d) => d.name.toLowerCase() == text.trim().toLowerCase())
        .firstOrNull;
    setState(() => _doctorId = match?.id);
    widget.onChanged(text, match?.id);
  }

  Future<void> _saveAsDoctor() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final d = await ref.read(doctorsProvider.notifier).create({'name': name});
      if (!mounted) return;
      _pick(d);
      showMessage(context, '$name added to My Doctors');
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctors = ref.watch(doctorsProvider).valueOrNull ?? const <Doctor>[];
    final linked = _doctorId != null;
    final label = widget.descriptor.required
        ? '${widget.descriptor.label} *'
        : widget.descriptor.label;

    return RawAutocomplete<Doctor>(
      textEditingController: _controller,
      focusNode: _focus,
      displayStringForOption: (d) => d.name,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        return doctors.where((d) =>
            q.isEmpty ||
            d.name.toLowerCase().contains(q) ||
            (d.speciality ?? '').toLowerCase().contains(q));
      },
      onSelected: _pick,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.words,
        onChanged: (t) => _typed(t, doctors),
        decoration: InputDecoration(
          labelText: label,
          errorText: widget.error,
          helperText: linked
              ? 'Linked to My Doctors'
              : controller.text.trim().isNotEmpty
                  ? 'Not in My Doctors — tap the icon to save'
                  : (doctors.isEmpty
                      ? null
                      : 'Start typing to pick from My Doctors'),
          prefixIcon: Icon(
              linked
                  ? Icons.verified_outlined
                  : Icons.medical_services_outlined,
              color: linked ? theme.colorScheme.primary : null),
          suffixIcon: !linked && controller.text.trim().isNotEmpty
              ? IconButton(
                  tooltip: 'Save to My Doctors',
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add_alt_outlined),
                  onPressed: _saving ? null : _saveAsDoctor,
                )
              : null,
        ),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260, maxWidth: 360),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final d in options)
                  ListTile(
                    dense: true,
                    leading:
                        const Icon(Icons.medical_services_outlined, size: 20),
                    title: Text(d.name),
                    subtitle: d.subtitle.isEmpty ? null : Text(d.subtitle),
                    onTap: () => onSelected(d),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
