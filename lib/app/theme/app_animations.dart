class AppAnimations {
  AppAnimations._();

  // Duration constants
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 350);

  // Stagger delays
  static const int staggerDelayMs = 50;
  static const int maxStaggerDelayMs = 300;
  static const int fabPressDelayMs = 100;

  // Scale values
  static const double pressedScale = 0.95;
  static const double selectedScale = 1.05;
  static const double normalScale = 1.0;
  static const double comingSoonStartScale = 0.8;

  /// Calculate stagger delay for list item at [index].
  static Duration staggerDelay(int index) {
    final ms = (index * staggerDelayMs).clamp(0, maxStaggerDelayMs);
    return Duration(milliseconds: ms);
  }
}
