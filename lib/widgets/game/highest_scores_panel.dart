import 'package:flutter/material.dart';

import '../../models/game_mode.dart';
import '../../utils/game_colors.dart';

class HighestScoresPanel extends StatelessWidget {
  final int timedHighestScore;
  final int unlimitedHighestScore;
  final int bestTime;

  const HighestScoresPanel({
    super.key,
    required this.timedHighestScore,
    required this.unlimitedHighestScore,
    required this.bestTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '历史最高总分',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GameColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildScoreItem(
          '限时模式',
          timedHighestScore,
        ),
        const SizedBox(height: 8),
        _buildScoreItem(
          '不限时模式',
          unlimitedHighestScore,
          additionalInfo: bestTime > 0 ? _formatTime(bestTime) : null,
        ),
      ],
    );
  }

  Widget _buildScoreItem(String label, int score, {String? additionalInfo}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.emptyTile.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GameColors.textColor,
                ),
              ),
              if (additionalInfo != null)
                Text(
                  '最佳: $additionalInfo',
                  style: TextStyle(
                    fontSize: 12,
                    color: GameColors.textColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: GameColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
