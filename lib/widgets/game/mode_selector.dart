import 'package:flutter/material.dart';

import '../../models/game_mode.dart';
import '../../utils/game_colors.dart';

class ModeSelector extends StatelessWidget {
  final GameMode currentMode;
  final GameVariant currentVariant;
  final Function(GameMode) onModeChanged;
  final Function(GameVariant) onVariantChanged;
  final String timeDisplay;
  final bool isTimedMode;
  final bool isVerticalButtons;
  final bool showTimePanel;
  final bool showVariantSelector;

  const ModeSelector({
    super.key,
    required this.currentMode,
    required this.currentVariant,
    required this.onModeChanged,
    required this.onVariantChanged,
    required this.timeDisplay,
    required this.isTimedMode,
    this.isVerticalButtons = false,
    this.showTimePanel = true,
    this.showVariantSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '时间模式',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: GameColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: isVerticalButtons
              ? _buildVerticalButtons()
              : _buildHorizontalButtons(),
        ),
        if (showVariantSelector) ...[
          const SizedBox(height: 16),
          _buildVariantSelector(),
        ],
        if (showTimePanel) ...[
          const SizedBox(height: 16),
          TimePanel(
            timeDisplay: timeDisplay,
            isTimedMode: isTimedMode,
          ),
        ],
      ],
    );
  }

  Widget _buildVariantSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '游戏模式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GameColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onVariantChanged(GameVariant.normal),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: currentVariant == GameVariant.normal
                          ? GameColors.buttonBackground
                          : Colors.transparent,
                      border: Border.all(
                        color: GameColors.buttonBackground,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8)),
                    ),
                    child: Text(
                      '常规模式',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: currentVariant == GameVariant.normal
                            ? Colors.white
                            : GameColors.textColor,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => onVariantChanged(GameVariant.fun),
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: currentVariant == GameVariant.fun
                          ? GameColors.buttonBackground
                          : Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: GameColors.buttonBackground,
                          width: 1.5,
                        ),
                        right: BorderSide(
                          color: GameColors.buttonBackground,
                          width: 1.5,
                        ),
                        bottom: BorderSide(
                          color: GameColors.buttonBackground,
                          width: 1.5,
                        ),
                      ),
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8)),
                    ),
                    child: Text(
                      '趣味模式',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: currentVariant == GameVariant.fun
                            ? Colors.white
                            : GameColors.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalButtons() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onModeChanged(GameMode.timed),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: currentMode == GameMode.timed
                      ? GameColors.buttonBackground
                      : Colors.transparent,
                  border: Border.all(
                    color: GameColors.buttonBackground,
                    width: 1.5,
                  ),
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(8)),
                ),
                child: Text(
                  '限时 10 分钟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: currentMode == GameMode.timed
                        ? Colors.white
                        : GameColors.textColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onModeChanged(GameMode.unlimited),
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(8)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: currentMode == GameMode.unlimited
                      ? GameColors.buttonBackground
                      : Colors.transparent,
                  border: Border(
                    top: BorderSide(
                      color: GameColors.buttonBackground,
                      width: 1.5,
                    ),
                    right: BorderSide(
                      color: GameColors.buttonBackground,
                      width: 1.5,
                    ),
                    bottom: BorderSide(
                      color: GameColors.buttonBackground,
                      width: 1.5,
                    ),
                  ),
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
                child: Text(
                  '不限时',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: currentMode == GameMode.unlimited
                        ? Colors.white
                        : GameColors.textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

class TimePanel extends StatelessWidget {
  final String timeDisplay;
  final bool isTimedMode;

  const TimePanel({
    super.key,
    required this.timeDisplay,
    required this.isTimedMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
