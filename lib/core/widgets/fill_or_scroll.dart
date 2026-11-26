import 'package:flutter/material.dart';

/// Lays out [child] to fill the screen (so Spacers work), but scrolls when it
/// doesn't fit — e.g. on phones with a large text size.
class FillOrScroll extends StatelessWidget {
  final Widget child;

  const FillOrScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
