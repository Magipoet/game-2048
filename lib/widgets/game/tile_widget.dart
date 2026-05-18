import 'package:flutter/material.dart';

import '../../models/cell_type.dart';
import '../../utils/game_colors.dart';

class TileWidget extends StatelessWidget {
  final Cell cell;
  final bool isNew;
  final bool isMerged;

  const TileWidget({
    super.key,
    required this.cell,
    this.isNew = false,
    this.isMerged = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTile(
      cell: cell,
      isNew: isNew,
      isMerged: isMerged,
    );
  }
}

class AnimatedTile extends StatefulWidget {
  final Cell cell;
  final bool isNew;
  final bool isMerged;

  const AnimatedTile({
    super.key,
    required this.cell,
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
    if (widget.isNew != oldWidget.isNew ||
        widget.isMerged != oldWidget.isMerged ||
        widget.cell.type != oldWidget.cell.type ||
        widget.cell.value != oldWidget.cell.value) {
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
    if (widget.cell.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: GameColors.emptyTile,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    final displayValue = widget.cell.isWoodBlock
        ? '木${widget.cell.remainingMerges}'
        : widget.cell.isIceBlock
            ? '${widget.cell.value}\n❄${widget.cell.remainingMoves}'
            : '${widget.cell.value}';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: GameColors.getTileColor(
              widget.cell.value,
              cellType: widget.cell.type,
            ),
            borderRadius: BorderRadius.circular(8),
            border: widget.cell.isIceBlock
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              displayValue,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: GameColors.getTileFontSize(
                  widget.cell.value,
                  cellType: widget.cell.type,
                ),
                fontWeight: FontWeight.bold,
                color: GameColors.getTileTextColor(
                  widget.cell.value,
                  cellType: widget.cell.type,
                ),
                height: widget.cell.isIceBlock ? 1.2 : 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
