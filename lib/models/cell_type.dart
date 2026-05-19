enum CellType {
  empty,
  number,
  woodBlock,
  frozenNumber,
}

class Cell {
  final CellType type;
  final int value;
  final int? remainingMerges;
  final int? remainingMoves;

  const Cell._({
    required this.type,
    this.value = 0,
    this.remainingMerges,
    this.remainingMoves,
  });

  factory Cell.empty() => const Cell._(type: CellType.empty);

  factory Cell.number(int value) => Cell._(type: CellType.number, value: value);

  factory Cell.woodBlock(int remainingMerges) =>
      Cell._(type: CellType.woodBlock, remainingMerges: remainingMerges);

  factory Cell.frozenNumber(int value, int remainingMoves) => Cell._(
        type: CellType.frozenNumber,
        value: value,
        remainingMoves: remainingMoves,
      );

  bool get isEmpty => type == CellType.empty;
  bool get isNumber => type == CellType.number;
  bool get isWoodBlock => type == CellType.woodBlock;
  bool get isFrozenNumber => type == CellType.frozenNumber;
  bool get hasValue => isNumber || isFrozenNumber;
  bool get isMovable => isNumber;
  bool get blocksMovement => isWoodBlock;

  Cell copyWith({
    CellType? type,
    int? value,
    int? remainingMerges,
    int? remainingMoves,
  }) {
    return Cell._(
      type: type ?? this.type,
      value: value ?? this.value,
      remainingMerges: remainingMerges ?? this.remainingMerges,
      remainingMoves: remainingMoves ?? this.remainingMoves,
    );
  }
}
