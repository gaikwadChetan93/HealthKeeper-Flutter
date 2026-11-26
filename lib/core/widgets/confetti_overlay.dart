import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Wraps [child] with a celebratory confetti burst that can be triggered on
/// demand via [ConfettiOverlayState.play] — used right after successfully
/// adding a health record or vital reading, so it feels like a small win
/// rather than just another form submission.
///
/// Usage: hold a `GlobalKey<ConfettiOverlayState>`, pass it as this widget's
/// `key`, and call `key.currentState?.play()` once the save succeeds.
class ConfettiOverlay extends StatefulWidget {
  final Widget child;

  const ConfettiOverlay({super.key, required this.child});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  late final ConfettiController _controller =
      ConfettiController(duration: const Duration(milliseconds: 700));

  void play() => _controller.play();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _controller,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 22,
                maxBlastForce: 18,
                minBlastForce: 7,
                gravity: 0.25,
                shouldLoop: false,
                colors: const [
                  AppColors.primary,
                  AppColors.hueOxygen,
                  AppColors.hueGlucose,
                  AppColors.hueTemperature,
                  AppColors.hueActivity,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
