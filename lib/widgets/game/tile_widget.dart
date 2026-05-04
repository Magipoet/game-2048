import 'package:flutter/material.dart';

import '../../logic/game_2048_logic.dart';
import '../../utils/game_colors.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final bool isNew;
  final bool isMerged;

  const TileWidget({
    super.key,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTile(
      value: value,
      isNew: isNew,
      isMerged: isMerged,
    );
  }
}

class AnimatedTile extends StatefulWidget {
  final int value;
  final bool isNew;
  final bool isMerged;

  const AnimatedTile({
    super.key,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
  });

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.isNew ? 0.0 : (widget.isMerged ? 1.2 : 1.0),
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.isNew ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNew != oldWidget.isNew || widget.isMerged != oldWidget.isMerged) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: GameColors.getTileColor(widget.value),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.value == 0 ? '' : '${widget.value}',
              style: TextStyle(
                fontSize: GameColors.getTileFontSize(widget.value),
                fontWeight: FontWeight.bold,
                color: GameColors.getTileTextColor(widget.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
