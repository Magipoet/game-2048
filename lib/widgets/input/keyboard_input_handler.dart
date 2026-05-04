import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../logic/game_2048_logic.dart';

class KeyboardInputHandler extends StatefulWidget {
  final Widget child;
  final Function(Direction) onMove;
  final bool enabled;
  final FocusNode focusNode;

  const KeyboardInputHandler({
    super.key,
    required this.child,
    required this.onMove,
    this.enabled = true,
    required this.focusNode,
  });

  @override
  State<KeyboardInputHandler> createState() => _KeyboardInputHandlerState();
}

class _KeyboardInputHandlerState extends State<KeyboardInputHandler> {
  bool _handleKeyEvent(KeyEvent event) {
    if (!widget.enabled) return false;

    if (event is KeyDownEvent) {
      Direction? direction;

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        direction = Direction.left;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        direction = Direction.right;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        direction = Direction.up;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        direction = Direction.down;
      }

      if (direction != null) {
        widget.onMove(direction);
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (node, event) {
        if (_handleKeyEvent(event)) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      autofocus: true,
      child: widget.child,
    );
  }
}
