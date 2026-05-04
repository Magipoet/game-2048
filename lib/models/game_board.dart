class GameBoard {
  List<List<int>> _board;
  static const int size = 4;

  GameBoard() : _board = List.generate(size, (_) => List.filled(size, 0));

  int getValue(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      throw ArgumentError('Row or column out of bounds: ($row, $col)');
    }
    return _board[row][col];
  }

  void setValue(int row, int col, int value) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      throw ArgumentError('Row or column out of bounds: ($row, $col)');
    }
    if (value < 0) {
      throw ArgumentError('Value cannot be negative: $value');
    }
    _board[row][col] = value;
  }

  List<(int, int)> getEmptyCells() {
    List<(int, int)> emptyCells = [];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_board[i][j] == 0) {
          emptyCells.add((i, j));
        }
      }
    }
    return emptyCells;
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
        if (_board[i][j] != other._board[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
}
