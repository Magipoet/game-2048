import 'cell_type.dart';

class GameBoard {
  List<List<Cell>> _board;
  static const int size = 4;

  GameBoard()
      : _board = List.generate(size, (_) => List.filled(size, Cell.empty()));

  Cell getCell(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      throw ArgumentError('Row or column out of bounds: ($row, $col)');
    }
    return _board[row][col];
  }

  int getValue(int row, int col) {
    return getCell(row, col).value;
  }

  void setCell(int row, int col, Cell cell) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      throw ArgumentError('Row or column out of bounds: ($row, $col)');
    }
    _board[row][col] = cell;
  }

  void setValue(int row, int col, int value) {
    if (value < 0) {
      throw ArgumentError('Value cannot be negative: $value');
    }
    setCell(row, col, Cell.number(value));
  }

  List<(int, int)> getEmptyCells() {
    List<(int, int)> emptyCells = [];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_board[i][j].isEmpty) {
          emptyCells.add((i, j));
        }
      }
    }
    return emptyCells;
  }

  bool hasWoodBlock() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_board[i][j].isWoodBlock) {
          return true;
        }
      }
    }
    return false;
  }

  (int, int)? findWoodBlock() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_board[i][j].isWoodBlock) {
          return (i, j);
        }
      }
    }
    return null;
  }

  List<(int, int)> getAdjacentCells(int row, int col) {
    List<(int, int)> adjacent = [];
    if (row > 0) adjacent.add((row - 1, col));
    if (row < size - 1) adjacent.add((row + 1, col));
    if (col > 0) adjacent.add((row, col - 1));
    if (col < size - 1) adjacent.add((row, col + 1));
    return adjacent;
  }

  GameBoard clone() {
    GameBoard newBoard = GameBoard();
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        newBoard._board[i][j] = _board[i][j];
      }
    }
    return newBoard;
  }

  bool equals(GameBoard other) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_board[i][j].type != other._board[i][j].type ||
            _board[i][j].value != other._board[i][j].value ||
            _board[i][j].remainingMerges !=
                other._board[i][j].remainingMerges ||
            _board[i][j].remainingMoves != other._board[i][j].remainingMoves) {
          return false;
        }
      }
    }
    return true;
  }
}
