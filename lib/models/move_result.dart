class MoveResult {
  final bool isValid;
  final int scoreAdded;

  MoveResult({
    required this.isValid,
    required this.scoreAdded,
  });
}

class RowResult {
  final List<int> row;
  final int scoreAdded;

  RowResult({
    required this.row,
    required this.scoreAdded,
  });
}
