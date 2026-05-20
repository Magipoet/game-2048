import 'package:flutter/material.dart';

import '../../utils/game_colors.dart';

class HighestScoresPanel extends StatelessWidget {
  final int timedNormalHighestScore;
  final int timedFunHighestScore;
  final int unlimitedNormalHighestScore;
  final int unlimitedFunHighestScore;
  final int unlimitedNormalBestTime;
  final int unlimitedFunBestTime;

  const HighestScoresPanel({
    super.key,
    required this.timedNormalHighestScore,
    required this.timedFunHighestScore,
    required this.unlimitedNormalHighestScore,
    required this.unlimitedFunHighestScore,
    required this.unlimitedNormalBestTime,
    required this.unlimitedFunBestTime,
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
          normalBestTime: unlimitedNormalBestTime,
          funBestTime: unlimitedFunBestTime,
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required int normalScore,
    required int funScore,
    int? normalBestTime,
    int? funBestTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.emptyTile.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: GameColors.textColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVariantRow(
                  label: '常规模式',
                  score: normalScore,
                  bestTime: normalBestTime,
                ),
                const SizedBox(height: 4),
                _buildVariantRow(
                  label: '趣味模式',
                  score: funScore,
                  bestTime: funBestTime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantRow({
    required String label,
    required int score,
    int? bestTime,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: GameColors.textColor,
            ),
          ),
        ),
        if (bestTime != null && bestTime > 0) ...[
          const SizedBox(width: 8),
          Text(
            '最佳: ${_formatTime(bestTime)}',
            style: TextStyle(
              fontSize: 12,
              color: GameColors.textColor.withOpacity(0.7),
            ),
          ),
        ],
        const Spacer(),
        SizedBox(
          width: 130,
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '分数: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textColor,
                  ),
                ),
                TextSpan(
                  text: score.toString().padLeft(6, ' '),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
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
