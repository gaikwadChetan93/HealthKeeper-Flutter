import 'package:flutter/material.dart';

/// Shared soft-shadow recipes lifted from the design's `box-shadow` values.
/// The design leans on large, low-opacity, negative-spread blurs rather than
/// Material elevation — these are used by [HkCard] and friends.
class AppShadows {
  AppShadows._();

  /// Barely-there shadow for flat list tiles and rows.
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x0A17211C), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// Standard raised card — subtle edge + soft ambient glow underneath.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A17211C), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x4717211C), offset: Offset(0, 14), blurRadius: 30, spreadRadius: -22),
  ];

  /// Larger raised card (hero cards, charts, backup panel).
  static const List<BoxShadow> cardLarge = [
    BoxShadow(color: Color(0x0A17211C), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x4D17211C), offset: Offset(0, 16), blurRadius: 30, spreadRadius: -24),
  ];

  /// Brand-tinted glow under the primary green button / FAB.
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(color: Color(0xCC1E4D3B), offset: Offset(0, 6), blurRadius: 14, spreadRadius: -6),
  ];

  /// Toast / sheet pop shadow.
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x9917211C), offset: Offset(0, 14), blurRadius: 30, spreadRadius: -12),
  ];
}
