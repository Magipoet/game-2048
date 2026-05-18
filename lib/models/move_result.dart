import 'cell_type.dart';

class MoveResult {
  final bool isValid;
  final int scoreAdded;

  MoveResult({
    required this.isValid,
    required this.scoreAdded,
  });
}

class RowResult {
  final List<Cell> cells;
  final int scoreAdded;

  RowResult({
    required this.cells,
    required this.scoreAdded,
  });
}
