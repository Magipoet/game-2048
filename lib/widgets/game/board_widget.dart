import 'package:flutter/material.dart';

import '../../models/game_board.dart';
import '../../utils/game_colors.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  final GameBoard board;
  final double size;
  final (int, int)? iceBlockPosition;
  final int iceBlockRemainingMoves;

  const BoardWidget({
    super.key,
    required this.board,
    required this.size,
    this.iceBlockPosition,
    this.iceBlockRemainingMoves = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GameColors.boardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              int row = index ~/ 4;
              int col = index % 4;
              final cell = board.getCell(row, col);

              return TileWidget(cell: cell);
            },
          ),
          if (iceBlockPosition != null) _buildIceBlockOverlay(),
        ],
      ),
    );
  }

  Widget _buildIceBlockOverlay() {
    final double spacing = 10;
    final double padding = 10;
    final double tileSize = (size - padding * 2 - spacing * 3) / 4;

    final row = iceBlockPosition!.$1;
    final col = iceBlockPosition!.$2;

    final double top = padding + row * (tileSize + spacing);
    final double left = padding + col * (tileSize + spacing);

    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.lightBlueAccent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.lightBlueAccent.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              right: 4,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '❄$iceBlockRemainingMoves',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
