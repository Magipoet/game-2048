import 'package:flutter/material.dart';

import '../../utils/game_colors.dart';

class ScorePanel extends StatelessWidget {
  final int score;
  final String label;

  const ScorePanel({
    super.key,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GameColors.scoreBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: GameColors.scoreTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GameColors.scoreTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentScorePanel extends StatelessWidget {
  final int score;

  const CurrentScorePanel({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.scoreBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前得分',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: GameColors.scoreTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: GameColors.scoreTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
