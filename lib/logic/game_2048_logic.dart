import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/game_board.dart';
import '../models/game_mode.dart';
import '../models/move_result.dart';

enum Direction {
  left,
  right,
  up,
  down,
}

class Game2048Logic extends ChangeNotifier {
  GameBoard _board;
  int _score;
  bool _gameOver;
  bool _gameWon;
  bool _continueAfterWin;
  bool _timerStarted;
  
  GameMode _currentMode = GameMode.unlimited;
  int _elapsedSeconds = 0;
  Timer? _gameTimer;
  static const int _timedModeDuration = 10 * 60;

  Game2048Logic() : 
    _board = GameBoard(),
    _score = 0,
    _gameOver = false,
    _gameWon = false,
    _continueAfterWin = false,
    _timerStarted = false;

  void initGame() {
    _board = GameBoard();
    _score = 0;
    _gameOver = false;
    _gameWon = false;
    _continueAfterWin = false;
    _elapsedSeconds = 0;
    _timerStarted = false;
    _addRandomTile();
    _addRandomTile();
  }

  void setMode(GameMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      stopTimer();
      initGame();
    }
  }

  void startTimer() {
    _gameTimer?.cancel();
    _elapsedSeconds = 0;
    _timerStarted = true;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
      
      if (_currentMode == GameMode.timed && _elapsedSeconds >= _timedModeDuration) {
        _gameOver = true;
        _gameTimer?.cancel();
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    _gameTimer?.cancel();
    _timerStarted = false;
  }

  void startTimerIfNeeded() {
    if (!_timerStarted) {
      startTimer();
    }
  }

  void pauseTimer() {
    _gameTimer?.cancel();
  }

  void resumeTimer() {
    if (_gameOver) return;
    
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
      
      if (_currentMode == GameMode.timed && _elapsedSeconds >= _timedModeDuration) {
        _gameOver = true;
        _gameTimer?.cancel();
        notifyListeners();
      }
    });
  }

  MoveResult move(Direction direction) {
    if (_gameOver && !_continueAfterWin) {
      return MoveResult(isValid: false, scoreAdded: 0);
    }

    GameBoard originalBoard = _board.clone();
    int scoreAdded = 0;

    switch (direction) {
      case Direction.left:
        scoreAdded = _moveLeft();
        break;
      case Direction.right:
        scoreAdded = _moveRight();
        break;
      case Direction.up:
        scoreAdded = _moveUp();
        break;
      case Direction.down:
        scoreAdded = _moveDown();
        break;
    }

    bool isValid = !originalBoard.equals(_board);

    if (isValid) {
      startTimerIfNeeded();
      _score += scoreAdded;
      _addRandomTile(direction);
      _checkGameState();
    }

    return MoveResult(isValid: isValid, scoreAdded: scoreAdded);
  }

  MoveResult safeMove(Direction direction) {
    try {
      return move(direction);
    } catch (e) {
      _logError('Error during move: $e');
      return MoveResult(isValid: false, scoreAdded: 0);
    }
  }

  int _moveLeft() {
    int scoreAdded = 0;
    for (int row = 0; row < GameBoard.size; row++) {
      List<int> rowData = List.generate(GameBoard.size, (col) => _board.getValue(row, col));
      RowResult result = _processRowLeft(rowData);
      scoreAdded += result.scoreAdded;
      for (int col = 0; col < GameBoard.size; col++) {
        _board.setValue(row, col, result.row[col]);
      }
    }
    return scoreAdded;
  }

  int _moveRight() {
    int scoreAdded = 0;
    for (int row = 0; row < GameBoard.size; row++) {
      List<int> rowData = List.generate(GameBoard.size, (col) => _board.getValue(row, col));
      RowResult result = _processRowRight(rowData);
      scoreAdded += result.scoreAdded;
      for (int col = 0; col < GameBoard.size; col++) {
        _board.setValue(row, col, result.row[col]);
      }
    }
    return scoreAdded;
  }

  int _moveUp() {
    int scoreAdded = 0;
    for (int col = 0; col < GameBoard.size; col++) {
      List<int> colData = List.generate(GameBoard.size, (row) => _board.getValue(row, col));
      RowResult result = _processRowLeft(colData);
      scoreAdded += result.scoreAdded;
      for (int row = 0; row < GameBoard.size; row++) {
        _board.setValue(row, col, result.row[row]);
      }
    }
    return scoreAdded;
  }

  int _moveDown() {
    int scoreAdded = 0;
    for (int col = 0; col < GameBoard.size; col++) {
      List<int> colData = List.generate(GameBoard.size, (row) => _board.getValue(row, col));
      RowResult result = _processRowRight(colData);
      scoreAdded += result.scoreAdded;
      for (int row = 0; row < GameBoard.size; row++) {
        _board.setValue(row, col, result.row[row]);
      }
    }
    return scoreAdded;
  }

  RowResult _processRowLeft(List<int> row) {
    int scoreAdded = 0;
    List<int> nonZero = row.where((value) => value != 0).toList();
    List<int> merged = [];

    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        int mergedValue = nonZero[i] * 2;
        merged.add(mergedValue);
        scoreAdded += mergedValue;
        i += 2;
      } else {
        merged.add(nonZero[i]);
        i++;
      }
    }

    while (merged.length < GameBoard.size) {
      merged.add(0);
    }

    return RowResult(row: merged, scoreAdded: scoreAdded);
  }

  RowResult _processRowRight(List<int> row) {
    List<int> reversedRow = List.from(row.reversed);
    RowResult result = _processRowLeft(reversedRow);
    return RowResult(
      row: List.from(result.row.reversed),
      scoreAdded: result.scoreAdded,
    );
  }

  void _addRandomTile([Direction? direction]) {
    List<(int, int)> emptyCells = _board.getEmptyCells();
    if (emptyCells.isEmpty) return;

    Random random = Random();
    List<(int, int)> candidateCells = [];

    if (direction != null) {
      switch (direction) {
        case Direction.left:
          candidateCells = emptyCells.where((cell) => cell.$2 == 3).toList();
          break;
        case Direction.right:
          candidateCells = emptyCells.where((cell) => cell.$2 == 0).toList();
          break;
        case Direction.up:
          candidateCells = emptyCells.where((cell) => cell.$1 == 3).toList();
          break;
        case Direction.down:
          candidateCells = emptyCells.where((cell) => cell.$1 == 0).toList();
          break;
      }
    }

    if (candidateCells.isEmpty) {
      candidateCells = emptyCells.where((cell) {
        return cell.$1 == 0 || cell.$1 == 3 || cell.$2 == 0 || cell.$2 == 3;
      }).toList();
    }

    if (candidateCells.isEmpty) {
      candidateCells = emptyCells;
    }

    (int, int) position = candidateCells[random.nextInt(candidateCells.length)];
    int value = random.nextDouble() < 0.9 ? 2 : 4;

    _board.setValue(position.$1, position.$2, value);
  }

  void _checkGameState() {
    if (!_gameWon) {
      for (int i = 0; i < GameBoard.size; i++) {
        for (int j = 0; j < GameBoard.size; j++) {
          if (_board.getValue(i, j) >= 2048) {
            _gameWon = true;
            return;
          }
        }
      }
    }

    _gameOver = _isGameOver();
  }

  bool _isGameOver() {
    if (_currentMode == GameMode.timed && _elapsedSeconds >= _timedModeDuration) {
      return true;
    }

    if (_board.getEmptyCells().isNotEmpty) {
      return false;
    }

    for (int i = 0; i < GameBoard.size; i++) {
      for (int j = 0; j < GameBoard.size - 1; j++) {
        if (_board.getValue(i, j) == _board.getValue(i, j + 1)) {
          return false;
        }
      }
    }

    for (int i = 0; i < GameBoard.size - 1; i++) {
      for (int j = 0; j < GameBoard.size; j++) {
        if (_board.getValue(i, j) == _board.getValue(i + 1, j)) {
          return false;
        }
      }
    }

    return true;
  }

  void continueAfterWin() {
    _continueAfterWin = true;
  }

  String getFormattedTime() {
    int timeToShow = _currentMode == GameMode.timed 
        ? max(0, _timedModeDuration - _elapsedSeconds)
        : _elapsedSeconds;
    
    int minutes = timeToShow ~/ 60;
    int seconds = timeToShow % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _logError(String message) {
    print('ERROR [Game2048Logic]: $message');
  }

  int get score => _score;
  bool get isGameOver => _gameOver;
  bool get isGameWon => _gameWon;
  bool get shouldShowWinDialog => _gameWon && !_continueAfterWin;
  GameBoard get board => _board;
  GameMode get currentMode => _currentMode;
  int get elapsedSeconds => _elapsedSeconds;
  int get remainingTime {
    if (_currentMode == GameMode.timed) {
      return max(0, _timedModeDuration - _elapsedSeconds);
    }
    return _elapsedSeconds;
  }

  int get maxTile {
    int maxValue = 0;
    for (int i = 0; i < GameBoard.size; i++) {
      for (int j = 0; j < GameBoard.size; j++) {
        int value = _board.getValue(i, j);
        if (value > maxValue) {
          maxValue = value;
        }
      }
    }
    return maxValue;
  }
}
