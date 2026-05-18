import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/cell_type.dart';
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
  GameVariant _currentVariant = GameVariant.normal;
  int _elapsedSeconds = 0;
  Timer? _gameTimer;
  static const int _timedModeDuration = 10 * 60;
  static const int _woodBlockRequiredMerges = 4;
  static const int _iceBlockMaxMoves = 4;

  final Random _random = Random();

  Game2048Logic()
      : _board = GameBoard(),
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

    if (_currentVariant == GameVariant.fun) {
      _trySpawnWoodBlock();
      _trySpawnIceBlock();
    }
  }

  void setMode(GameMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      stopTimer();
      initGame();
    }
  }

  void setVariant(GameVariant variant) {
    if (_currentVariant != variant) {
      _currentVariant = variant;
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

      if (_currentMode == GameMode.timed &&
          _elapsedSeconds >= _timedModeDuration) {
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

      if (_currentMode == GameMode.timed &&
          _elapsedSeconds >= _timedModeDuration) {
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
    List<(int, int)> mergePositions = [];

    switch (direction) {
      case Direction.left:
        scoreAdded = _moveLeft(mergePositions);
        break;
      case Direction.right:
        scoreAdded = _moveRight(mergePositions);
        break;
      case Direction.up:
        scoreAdded = _moveUp(mergePositions);
        break;
      case Direction.down:
        scoreAdded = _moveDown(mergePositions);
        break;
    }

    bool isValid = !originalBoard.equals(_board);

    if (isValid) {
      startTimerIfNeeded();
      _score += scoreAdded;

      if (_currentVariant == GameVariant.fun) {
        _processFunModeAfterMove(mergePositions);
      }

      _addRandomTile(direction);
      _checkGameState();
    }

    return MoveResult(isValid: isValid, scoreAdded: scoreAdded);
  }

  void _processFunModeAfterMove(List<(int, int)> mergePositions) {
    final woodBlockPos = _board.findWoodBlock();
    if (woodBlockPos != null) {
      int mergeCount = 0;
      final adjacentCells =
          _board.getAdjacentCells(woodBlockPos.$1, woodBlockPos.$2);
      for (final mergePos in mergePositions) {
        if (adjacentCells.contains(mergePos)) {
          mergeCount++;
        }
      }

      if (mergeCount > 0) {
        final woodCell = _board.getCell(woodBlockPos.$1, woodBlockPos.$2);
        final newRemaining = (woodCell.remainingMerges ?? 0) - mergeCount;
        if (newRemaining <= 0) {
          _board.setCell(woodBlockPos.$1, woodBlockPos.$2, Cell.empty());
        } else {
          _board.setCell(
            woodBlockPos.$1,
            woodBlockPos.$2,
            woodCell.copyWith(remainingMerges: newRemaining),
          );
        }
      }
    }

    _decrementIceBlocks(mergePositions);
    _trySpawnWoodBlock();
    _trySpawnIceBlock();
  }

  void _decrementIceBlocks(List<(int, int)> mergePositions) {
    List<(int, int, Cell)> cellsToUpdate = [];

    for (int i = 0; i < GameBoard.size; i++) {
      for (int j = 0; j < GameBoard.size; j++) {
        final cell = _board.getCell(i, j);
        if (cell.isIceBlock) {
          int newRemaining = (cell.remainingMoves ?? 0) - 1;
          if (mergePositions.contains((i, j))) {
            newRemaining -= 1;
          }
          if (newRemaining <= 0) {
            cellsToUpdate.add((i, j, Cell.number(cell.value)));
          } else {
            cellsToUpdate.add(
                (i, j, cell.copyWith(remainingMoves: newRemaining)));
          }
        }
      }
    }

    for (final update in cellsToUpdate) {
      _board.setCell(update.$1, update.$2, update.$3);
    }
  }

  void _trySpawnWoodBlock() {
    if (_board.hasWoodBlock()) return;

    final emptyCells = _board.getEmptyCells();
    if (emptyCells.isEmpty) return;

    if (_random.nextDouble() < 0.15) {
      final pos = emptyCells[_random.nextInt(emptyCells.length)];
      _board.setCell(
          pos.$1, pos.$2, Cell.woodBlock(_woodBlockRequiredMerges));
    }
  }

  void _trySpawnIceBlock() {
    final emptyCells = _board.getEmptyCells();
    if (emptyCells.isEmpty) return;

    if (_random.nextDouble() < 0.1) {
      final pos = emptyCells[_random.nextInt(emptyCells.length)];
      int value = _random.nextDouble() < 0.9 ? 2 : 4;
      _board.setCell(pos.$1, pos.$2,
          Cell.iceBlock(value: value, remainingMoves: _iceBlockMaxMoves));
    }
  }

  MoveResult safeMove(Direction direction) {
    try {
      return move(direction);
    } catch (e) {
      _logError('Error during move: $e');
      return MoveResult(isValid: false, scoreAdded: 0);
    }
  }

  int _moveLeft(List<(int, int)> mergePositions) {
    int scoreAdded = 0;
    for (int row = 0; row < GameBoard.size; row++) {
      List<Cell> rowData =
          List.generate(GameBoard.size, (col) => _board.getCell(row, col));
      RowResult result = _processRowLeft(rowData, mergePositions, row);
      scoreAdded += result.scoreAdded;
      for (int col = 0; col < GameBoard.size; col++) {
        _board.setCell(row, col, result.cells[col]);
      }
    }
    return scoreAdded;
  }

  int _moveRight(List<(int, int)> mergePositions) {
    int scoreAdded = 0;
    for (int row = 0; row < GameBoard.size; row++) {
      List<Cell> rowData =
          List.generate(GameBoard.size, (col) => _board.getCell(row, col));
      RowResult result = _processRowRight(rowData, mergePositions, row);
      scoreAdded += result.scoreAdded;
      for (int col = 0; col < GameBoard.size; col++) {
        _board.setCell(row, col, result.cells[col]);
      }
    }
    return scoreAdded;
  }

  int _moveUp(List<(int, int)> mergePositions) {
    int scoreAdded = 0;
    for (int col = 0; col < GameBoard.size; col++) {
      List<Cell> colData =
          List.generate(GameBoard.size, (row) => _board.getCell(row, col));
      RowResult result = _processRowLeft(colData, mergePositions, -1, col);
      scoreAdded += result.scoreAdded;
      for (int row = 0; row < GameBoard.size; row++) {
        _board.setCell(row, col, result.cells[row]);
      }
    }
    return scoreAdded;
  }

  int _moveDown(List<(int, int)> mergePositions) {
    int scoreAdded = 0;
    for (int col = 0; col < GameBoard.size; col++) {
      List<Cell> colData =
          List.generate(GameBoard.size, (row) => _board.getCell(row, col));
      RowResult result = _processRowRight(colData, mergePositions, -1, col);
      scoreAdded += result.scoreAdded;
      for (int row = 0; row < GameBoard.size; row++) {
        _board.setCell(row, col, result.cells[row]);
      }
    }
    return scoreAdded;
  }

  RowResult _processRowLeft(List<Cell> row, List<(int, int)> mergePositions,
      [int rowIdx = -1, int colIdx = -1]) {
    int scoreAdded = 0;
    List<Cell> result = List.filled(row.length, Cell.empty());

    List<List<Cell>> segments = [];
    List<int> segmentStartIndices = [];
    List<Cell> currentSegment = [];
    int currentStart = 0;

    for (int i = 0; i < row.length; i++) {
      final cell = row[i];
      if (cell.isWoodBlock || cell.isIceBlock) {
        if (currentSegment.isNotEmpty) {
          segments.add(currentSegment);
          segmentStartIndices.add(currentStart);
          currentSegment = [];
        }
        segments.add([cell]);
        segmentStartIndices.add(i);
        currentStart = i + 1;
      } else {
        if (currentSegment.isEmpty) {
          currentStart = i;
        }
        currentSegment.add(cell);
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
      segmentStartIndices.add(currentStart);
    }

    for (int segIdx = 0; segIdx < segments.length; segIdx++) {
      final segment = segments[segIdx];
      final startIdx = segmentStartIndices[segIdx];

      if (segment.length == 1 &&
          (segment[0].isWoodBlock || segment[0].isIceBlock)) {
        result[startIdx] = segment[0];
        continue;
      }

      List<Cell> numbers = segment.where((c) => c.isNumber).toList();
      List<Cell> processed = [];
      int i = 0;
      while (i < numbers.length) {
        if (i + 1 < numbers.length &&
            numbers[i].value == numbers[i + 1].value) {
          int mergedValue = numbers[i].value * 2;
          processed.add(Cell.number(mergedValue));
          scoreAdded += mergedValue;

          int mergePos = startIdx + processed.length - 1;
          if (rowIdx >= 0) {
            mergePositions.add((rowIdx, mergePos));
          } else {
            mergePositions.add((mergePos, colIdx));
          }
          i += 2;
        } else {
          processed.add(numbers[i]);
          i++;
        }
      }

      for (int j = 0; j < processed.length; j++) {
        result[startIdx + j] = processed[j];
      }
    }

    return RowResult(cells: result, scoreAdded: scoreAdded);
  }

  RowResult _processRowRight(List<Cell> row, List<(int, int)> mergePositions,
      [int rowIdx = -1, int colIdx = -1]) {
    List<Cell> reversedRow = List.from(row.reversed);
    RowResult result = _processRowLeft(reversedRow, mergePositions, rowIdx, colIdx);
    return RowResult(
      cells: List.from(result.cells.reversed),
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
    if (_currentMode == GameMode.timed &&
        _elapsedSeconds >= _timedModeDuration) {
      return true;
    }

    if (_board.getEmptyCells().isNotEmpty) {
      return false;
    }

    for (int i = 0; i < GameBoard.size; i++) {
      for (int j = 0; j < GameBoard.size - 1; j++) {
        final cell1 = _board.getCell(i, j);
        final cell2 = _board.getCell(i, j + 1);
        if (cell1.isNumber &&
            cell2.isNumber &&
            cell1.value == cell2.value) {
          return false;
        }
      }
    }

    for (int i = 0; i < GameBoard.size - 1; i++) {
      for (int j = 0; j < GameBoard.size; j++) {
        final cell1 = _board.getCell(i, j);
        final cell2 = _board.getCell(i + 1, j);
        if (cell1.isNumber &&
            cell2.isNumber &&
            cell1.value == cell2.value) {
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
  GameVariant get currentVariant => _currentVariant;
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
