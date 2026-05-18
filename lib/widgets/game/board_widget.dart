import 'package:flutter/material.dart';

import '../../models/game_board.dart';
import '../../utils/game_colors.dart';
import 'tile_widget.dart';

class BoardWidget extends StatelessWidget {
  final GameBoard board;
  final double size;

  const BoardWidget({
    super.key,
    required this.board,
    required this.size,
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
      child: GridView.builder(
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
          int value = board.getValue(row, col);

          return TileWidget(value: value);
        },
      ),
    );
  }
}
