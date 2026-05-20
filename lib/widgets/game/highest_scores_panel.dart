import 'package:flutter/material.dart';

import '../../utils/game_colors.dart';

class HighestScoresPanel extends StatelessWidget {
  final int timedNormalHighestScore;
  final int timedFunHighestScore;
  final int unlimitedNormalHighestScore;
  final int unlimitedFunHighestScore;
  final int bestTime;

  const HighestScoresPanel({
    super.key,
    required this.timedNormalHighestScore,
    required this.timedFunHighestScore,
    required this.unlimitedNormalHighestScore,
    required this.unlimitedFunHighestScore,
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
        _buildModeCard(
          title: '限时模式',
          normalScore: timedNormalHighestScore,
          funScore: timedFunHighestScore,
        ),
        const SizedBox(height: 8),
        _buildModeCard(
          title: '不限时模式',
          normalScore: unlimitedNormalHighestScore,
          funScore: unlimitedFunHighestScore,
          additionalInfo: bestTime > 0 ? _formatTime(bestTime) : null,
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required int normalScore,
    required int funScore,
    String? additionalInfo,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.emptyTile.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
            ],
          ),
          const SizedBox(height: 8),
          _buildVariantRow('常规模式', normalScore),
          const SizedBox(height: 4),
          _buildVariantRow('趣味模式', funScore),
        ],
      ),
    );
  }

  Widget _buildVariantRow(String label, int score) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: GameColors.textColor.withOpacity(0.75),
            ),
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GameColors.textColor,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
