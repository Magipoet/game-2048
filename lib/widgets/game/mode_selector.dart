import 'package:flutter/material.dart';

import '../../models/game_mode.dart';
import '../../utils/game_colors.dart';

class ModeSelector extends StatelessWidget {
  final GameMode currentMode;
  final Function(GameMode) onModeChanged;
  final String timeDisplay;
  final bool isTimedMode;
  final bool isVerticalButtons;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.timeDisplay,
    required this.isTimedMode,
    this.isVerticalButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '游戏模式',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GameColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        isVerticalButtons
            ? _buildVerticalButtons()
            : _buildHorizontalButtons(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GameColors.scoreBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTimedMode ? '剩余时间' : '已用时间',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: GameColors.scoreTextColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeDisplay,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GameColors.scoreTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalButtons() {
    return ToggleButtons(
      isSelected: [
        currentMode == GameMode.timed,
        currentMode == GameMode.unlimited,
      ],
      onPressed: (index) {
        onModeChanged(index == 0 ? GameMode.timed : GameMode.unlimited);
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: GameColors.buttonBackground,
      color: GameColors.textColor,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('限时 10 分钟'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('不限时'),
        ),
      ],
    );
  }

  Widget _buildVerticalButtons() {
    return Column(
      children: [
        _buildModeButton(
          label: '限时 10 分钟',
          isSelected: currentMode == GameMode.timed,
          onTap: () => onModeChanged(GameMode.timed),
          isFirst: true,
        ),
        _buildModeButton(
          label: '不限时',
          isSelected: currentMode == GameMode.unlimited,
          onTap: () => onModeChanged(GameMode.unlimited),
          isFirst: false,
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isFirst,
  }) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(8) : Radius.zero,
          bottom: !isFirst ? const Radius.circular(8) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? GameColors.buttonBackground : Colors.transparent,
            border: Border.all(
              color: GameColors.buttonBackground,
              width: 1.5,
            ),
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(8) : Radius.zero,
              bottom: !isFirst ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : GameColors.textColor,
            ),
          ),
        ),
      ),
    );
  }
}
