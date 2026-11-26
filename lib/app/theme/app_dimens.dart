class AppDimens {
  AppDimens._();

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;

  // Component sizes
  static const double iconSize = 24;
  static const double avatarSize = 56;
  static const double fabSize = 56;
  static const double bottomNavHeight = 40;
  static const double headerHeight = 120;

  // Corner radius
  static const double radiusS = 8;
  static const double radiusM = 14;
  static const double radiusL = 16;
  static const double radiusXL = 49;
  static const double radiusXXL = 53;

  // Redesign radius scale — cards, tiles, chips, buttons in the new design
  // use larger, softer radii than the original Material defaults above.
  static const double radiusCardL = 24; // hero cards, empty states
  static const double radiusCardM = 20; // standard cards
  static const double radiusTile = 18; // list tiles, category rows
  static const double radiusTileS = 15; // small buttons, stat tiles
  static const double radiusChip = 12; // icon chips inside a tile
  static const double radiusPill = 999; // fully-rounded chips/pills

  // Card elevation
  static const double elevationS = 2;
  static const double elevationM = 4;
  static const double elevationL = 8;

  // Animation translation
  static const double animationTranslationY = 20;

  // Responsive breakpoints
  static const double compactWidth = 600;
  static const double mediumWidth = 840;
  static const double expandedWidth = 1200;
}
