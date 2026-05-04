import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/game_2048_logic.dart';
import '../models/game_mode.dart';
import '../models/move_result.dart';
import '../services/storage_service.dart';
import '../utils/game_colors.dart';
import '../utils/input_coordinator.dart';
import '../widgets/game/board_widget.dart';
import '../widgets/game/highest_scores_panel.dart';
import '../widgets/game/mode_selector.dart';
import '../widgets/game/score_panel.dart';
import '../widgets/input/focus_manager_widget.dart';
import '../widgets/input/gesture_input_handler.dart';
import '../widgets/input/keyboard_input_handler.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game2048Logic _gameLogic;
  late StorageService _storageService;
  late InputCoordinator _inputCoordinator;
  final FocusNode _focusNode = FocusNode();

  bool _showHelpDialog = false;
  bool _showWinDialog = false;
  bool _showGameOverDialog = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _gameLogic = Game2048Logic();
    _inputCoordinator = InputCoordinator();
    _initServices();
  }

  Future<void> _initServices() async {
    _storageService = await StorageServiceProvider.getInstance();
    setState(() {
      _isInitialized = true;
      _gameLogic.initGame();
      _gameLogic.startTimer();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _gameLogic.stopTimer();
    super.dispose();
  }

  Future<void> _handleMove(Direction direction) async {
    if (_inputCoordinator.isProcessing) return;

    await _inputCoordinator.tryProcessInput(() async {
      MoveResult result = _gameLogic.safeMove(direction);

      if (result.isValid) {
        setState(() {});
        _checkGameState();
      }
    });
  }

  void _checkGameState() {
    if (_gameLogic.isGameWon && !_showWinDialog) {
      _showWinDialog = true;
      _gameLogic.pauseTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWinGameDialog();
      });
    } else if (_gameLogic.isGameOver && !_showGameOverDialog) {
      _showGameOverDialog = true;
      _gameLogic.stopTimer();
      _updateHighScores();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialogFunc();
      });
    }
  }

  Future<void> _updateHighScores() async {
    if (!_isInitialized) return;

    await _storageService.setHighestScore(
      _gameLogic.currentMode,
      _gameLogic.score,
    );

    if (_gameLogic.currentMode == GameMode.unlimited && _gameLogic.isGameWon) {
      await _storageService.setBestTime(_gameLogic.elapsedSeconds);
    }
  }

  void _resetGame() {
    setState(() {
      _gameLogic.stopTimer();
      _gameLogic.initGame();
      _gameLogic.startTimer();
      _showWinDialog = false;
      _showGameOverDialog = false;
    });
  }

  void _continueGame() {
    setState(() {
      _showWinDialog = false;
      _gameLogic.continueAfterWin();
      _gameLogic.resumeTimer();
    });
  }

  void _showHelp() {
    setState(() {
      _showHelpDialog = true;
    });
  }

  void _closeHelpDialog() {
    setState(() {
      _showHelpDialog = false;
    });
  }

  void _changeMode(GameMode mode) {
    if (_gameLogic.currentMode != mode) {
      setState(() {
        _gameLogic.setMode(mode);
        _gameLogic.startTimer();
        _showWinDialog = false;
        _showGameOverDialog = false;
      });
    }
  }

  void _showWinGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 恭喜获胜！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '你成功合成了 2048！',
              style: TextStyle(fontSize: 16, color: GameColors.textColor),
            ),
            const SizedBox(height: 16),
            Text(
              '当前得分: ${_gameLogic.score}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: GameColors.textColor,
              ),
            ),
            if (_gameLogic.currentMode == GameMode.unlimited)
              Text(
                '用时: ${_gameLogic.getFormattedTime()}',
                style: TextStyle(fontSize: 16, color: GameColors.textColor),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _continueGame();
            },
            child: const Text('继续游戏'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.buttonBackground,
            ),
            child: Text(
              '新游戏',
              style: TextStyle(color: GameColors.buttonTextColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialogFunc() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _gameLogic.currentMode == GameMode.timed && _gameLogic.remainingTime <= 0
                  ? '时间耗尽！'
                  : '无法继续移动了',
              style: TextStyle(fontSize: 16, color: GameColors.textColor),
            ),
            const SizedBox(height: 16),
            Text(
              '最终得分',
              style: TextStyle(fontSize: 14, color: GameColors.textColor.withOpacity(0.7)),
            ),
            Text(
              '${_gameLogic.score}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: GameColors.textColor,
              ),
            ),
            if (_gameLogic.currentMode == GameMode.unlimited)
              Text(
                '用时: ${_gameLogic.getFormattedTime()}',
                style: TextStyle(fontSize: 16, color: GameColors.textColor),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.buttonBackground,
            ),
            child: Text(
              '新游戏',
              style: TextStyle(color: GameColors.buttonTextColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: GameColors.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      body: SafeArea(
        child: FocusManagerWidget(
          focusNode: _focusNode,
          child: KeyboardInputHandler(
            focusNode: _focusNode,
            onMove: _handleMove,
            enabled: !_inputCoordinator.isProcessing,
            child: GestureInputHandler(
              onMove: _handleMove,
              enabled: !_inputCoordinator.isProcessing,
              child: _buildGameLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double minDimension = min(constraints.maxWidth, constraints.maxHeight);
        double boardSize = minDimension * 0.8;

        return Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.help_outline, size: 28),
                color: GameColors.textColor,
                onPressed: _showHelp,
                tooltip: '游戏帮助',
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            '2048消消乐',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: GameColors.textColor,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: BoardWidget(
                            board: _gameLogic.board,
                            size: boardSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        ModeSelector(
                          currentMode: _gameLogic.currentMode,
                          onModeChanged: _changeMode,
                          timeDisplay: _gameLogic.getFormattedTime(),
                          isTimedMode: _gameLogic.currentMode == GameMode.timed,
                        ),
                        const SizedBox(height: 24),
                        CurrentScorePanel(score: _gameLogic.score),
                        const SizedBox(height: 16),
                        HighestScoresPanel(
                          timedHighestScore: _storageService.getHighestScore(GameMode.timed),
                          unlimitedHighestScore: _storageService.getHighestScore(GameMode.unlimited),
                          bestTime: _storageService.getBestTime(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_showHelpDialog) _buildHelpDialog(),
          ],
        );
      },
    );
  }

  Widget _buildHelpDialog() {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withOpacity(0.5),
          dismissible: true,
          onDismiss: _closeHelpDialog,
        ),
        Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              title: const Text('游戏玩法说明'),
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '基本规则',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• 使用方向键（↑↓←→）或滑动屏幕移动方块'),
                  Text('• 相同数字的方块碰撞时会合并为两者之和'),
                  Text('• 每次有效移动后，空白处会随机出现 2 或 4'),
                  Text('• 合并数字会获得分数（例如 2+2=4，获得 4 分）'),
                  SizedBox(height: 16),
                  Text(
                    '游戏模式',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• 限时 10 分钟：在 10 分钟内尽可能获得高分'),
                  Text('• 不限时：无时间限制，但会记录游戏时间'),
                  SizedBox(height: 16),
                  Text(
                    '游戏结束',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• 棋盘被填满且无法合并任何方块时游戏结束'),
                  Text('• 限时模式中时间耗尽也会结束游戏'),
                  SizedBox(height: 16),
                  Text(
                    '游戏目标',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• 合成出 2048 即可获胜'),
                  Text('• 获胜后可继续游戏挑战更高分数'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _closeHelpDialog,
                  child: const Text('知道了'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
