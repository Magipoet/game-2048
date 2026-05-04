import 'package:flutter/material.dart';

import '../../logic/game_2048_logic.dart';

class GestureInputHandler extends StatelessWidget {
  final Widget child;
  final Function(Direction) onMove;
  final bool enabled;
  final double minSwipeDistance;

  const GestureInputHandler({
    super.key,
    required this.child,
    required this.onMove,
    this.enabled = true,
    this.minSwipeDistance = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    Offset? _startPosition;

    return GestureDetector(
      onPanStart: (details) {
        if (enabled) {
          _startPosition = details.localPosition;
        }
      },
      onPanEnd: (details) {
        if (!enabled || _startPosition == null) return;

        Offset endPosition = details.localPosition;
        double dx = endPosition.dx - _startPosition!.dx;
        double dy = endPosition.dy - _startPosition!.dy;

        if (dx.abs() > dy.abs()) {
          if (dx.abs() >= minSwipeDistance) {
            if (dx > 0) {
              onMove(Direction.right);
            } else {
              onMove(Direction.left);
            }
          }
        } else {
          if (dy.abs() >= minSwipeDistance) {
            if (dy > 0) {
              onMove(Direction.down);
            } else {
              onMove(Direction.up);
            }
          }
        }

        _startPosition = null;
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
