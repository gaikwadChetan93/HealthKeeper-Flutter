import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';

enum ScreenSize { compact, medium, expanded }

class Responsive {
  Responsive._();

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppDimens.compactWidth) return ScreenSize.compact;
    if (width < AppDimens.mediumWidth) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static bool isCompact(BuildContext context) =>
      getScreenSize(context) == ScreenSize.compact;

  static bool isTablet(BuildContext context) =>
      getScreenSize(context) != ScreenSize.compact;

  static int gridColumns(BuildContext context) {
    return switch (getScreenSize(context)) {
      ScreenSize.compact => 2,
      ScreenSize.medium => 3,
      ScreenSize.expanded => 4,
    };
  }

  static double contentMaxWidth(BuildContext context) {
    return switch (getScreenSize(context)) {
      ScreenSize.compact => double.infinity,
      ScreenSize.medium => 720,
      ScreenSize.expanded => 960,
    };
  }
}
