import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// Circular monogram avatar used for family members throughout the
/// redesign: initials on a tint of the person's assigned hue, with an
/// optional ring to mark the currently-active person.
class HkPersonAvatar extends StatelessWidget {
  final String initials;
  final Color hue;
  final double size;
  final bool active;

  const HkPersonAvatar({
    super.key,
    required this.initials,
    required this.hue,
    this.size = 46,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tint(hue, 0.16),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
          color: hue,
        ),
      ),
    );

    if (!active) return avatar;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.white, blurRadius: 0, spreadRadius: 2),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: avatar,
      ),
    );
  }
}
